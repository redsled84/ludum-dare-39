local vector = require 'libs.vector'

-- v1 is the mouse coords
-- v2 is upper left position
-- v3 are dimensions
local function pointInBounds(v1, v2, v3)
  return v1.x > v2.x and v1.x < v2.x + v3.x and v1.y > v2.y and v1.y < v2.y + v3.y
end

local buttonFont = love.graphics.newFont('fonts/ARCADECLASSIC.TTF', 32)
buttonFont:setFilter('nearest', 'nearest')
local controlsFont = love.graphics.newFont('fonts/ARCADECLASSIC.TTF', 26)
controlsFont:setFilter('nearest', 'nearest')
local pauseBox = {
  position = vector(35, 120),
  dimensions = vector(love.graphics.getWidth()-70, love.graphics.getHeight()-200)
}
local resume = {
  name = 'resume',
  position = vector(pauseBox.position.x+8, pauseBox.position.y+8),
  dimensions = vector(130, 60),
  str = love.graphics.newText(buttonFont, 'RESUME'),
  hovered = false,
}
local restart = {
  name = 'restart',
  position = vector(resume.position.x+resume.dimensions.x+8, resume.position.y),
  dimensions = vector(140, 60),
  str = love.graphics.newText(buttonFont, '      LOAD'),
  hovered = false,
}
local quit = {
  name = 'quit',
  position = vector(restart.position.x+restart.dimensions.x+8, restart.position.y),
  dimensions = vector(90, 60),
  str = love.graphics.newText(buttonFont, 'QUIT'),
  hovered = false,
}
local music = {
  name = 'music',
  position = vector(quit.position.x+quit.dimensions.x+8, quit.position.y),
  dimensions = vector(168, 60),
  str = love.graphics.newText(buttonFont, 'MUSIC  ON'),
  hovered = false,
  enabled = true,
}

local buttons = { resume, restart, quit, music }

local Pause = {isPaused = false, buttons = buttons}

function Pause.update()
  local v1 = vector(love.mouse.getX(), love.mouse.getY())
  for i = 1, #buttons do
    local button = buttons[i]
    button.hovered = pointInBounds(v1, button.position, button.dimensions)
    if button.name == 'music' then
      if button.enabled then
        button.str:set('MUSIC   ON')
      else
        button.str:set('MUSIC  OFF')
      end
    end
  end
end

local controlsBox = {
  position = vector(resume.position.x, resume.position.y + resume.dimensions.y + 10),
  dimensions = vector(pauseBox.dimensions.x-16, 380)
}
local controls = love.graphics.newText(controlsFont, "CONTROLS")
local W = love.graphics.newText(controlsFont, "w   TO   MOVE  PLAYER  UP")
local A = love.graphics.newText(controlsFont, "a   TO   MOVE  PLAYER  LEFT")
local S = love.graphics.newText(controlsFont, "s   TO   MOVE  PLAYER  DOWN")
local D = love.graphics.newText(controlsFont, "d   TO   MOVE  PLAYER  RIGHT")
local SPACE = love.graphics.newText(controlsFont, "spacebar   TO   SHOOT  A  PROJECTILE")
local E = love.graphics.newText(controlsFont, "e   TO   PICK  UP  AND  DROP  A  CRYSTAL")
local note = love.graphics.newText(controlsFont, "NOTE")
local tip = love.graphics.newText(controlsFont, "SHOOTING  A  PROJECTILE  REQUIRES")
local tip2 = love.graphics.newText(controlsFont,  "A  CRYSTAL")

local credits = love.graphics.newText(controlsFont, "MADE  BY  ALEX  YANG  AND  LUCAS  BLACK")

function Pause.draw(s)
  -- love.graphics.setColor(255, 255, 255, 180)
  -- love.graphics.rectangle('fill', pauseBox.position.x, pauseBox.position.y, pauseBox.dimensions.x, pauseBox.dimensions.y)

  local alpha = 225
  for i = 1, #buttons do
    local button = buttons[i]
    if not button.hovered then
      love.graphics.setColor(25, 25, 25, alpha)
    else
      love.graphics.setColor(0, 0, 0, alpha)
    end
    love.graphics.rectangle('fill', button.position.x, button.position.y, button.dimensions.x, button.dimensions.y)
    love.graphics.setColor(235, 235, 235, alpha)
    local xOffset, yOffset = 10, 15
    love.graphics.draw(button.str, button.position.x+xOffset, button.position.y+yOffset)
  end

  love.graphics.setColor(25, 25, 25, alpha)
  love.graphics.rectangle('fill', controlsBox.position.x, controlsBox.position.y,
    controlsBox.dimensions.x, controlsBox.dimensions.y)
  love.graphics.setColor(235,235,235,alpha)
  local buffer = 25
  love.graphics.draw(controls, controlsBox.position.x+18, controlsBox.position.y + buffer)
  love.graphics.draw(W, controlsBox.position.x+80, controlsBox.position.y + buffer*2)
  love.graphics.draw(A, controlsBox.position.x+80, controlsBox.position.y + buffer*3)
  love.graphics.draw(S, controlsBox.position.x+80, controlsBox.position.y + buffer*4)
  love.graphics.draw(D, controlsBox.position.x+80, controlsBox.position.y + buffer*5)
  love.graphics.draw(SPACE, controlsBox.position.x+80, controlsBox.position.y + buffer*6)
  love.graphics.draw(E, controlsBox.position.x+80, controlsBox.position.y + buffer*7)
  love.graphics.draw(note, controlsBox.position.x+18, controlsBox.position.y + buffer*9)
  love.graphics.draw(tip, controlsBox.position.x+80, controlsBox.position.y + buffer*10)
  love.graphics.draw(tip2, controlsBox.position.x+80, controlsBox.position.y + buffer*11)

  love.graphics.draw(credits, controlsBox.position.x+65, controlsBox.position.y + buffer*13)
end

function Pause.mousepressed(x, y, button, game, theme)
  for i = 1, #buttons do
    local b = buttons[i]
    if button == 1 and b.hovered then
      if b.name == 'resume' then
        Pause.isPaused = false
      end
      if b.name == 'restart' then
        game:load()
        Pause.isPaused = false
      end
      if b.name == 'quit' then
        love.event.quit()
      end
      if b.name == 'music' then
        b.enabled = not b.enabled
        if b.enabled then
          theme:play()
        else
          theme:pause()
        end
      end
    end
  end
end

return Pause
