math.randomseed(os.time())
-- generate 3 randoms b/c programmer superstition :-P
math.random()
math.random()
math.random()

-- src
local Game = require 'src.game'

-- General stuff:
--   * love.load executed once at the first (or close too) frame(s)
--   * love.update executes every frame
--   * love.draw executes every frame
--   * love.keypressed exectures when any key has been pressed

-- Also, the `#` operator means length of (much like `len` in Python)

-- You'll notice order functions are defined in source files are generally following this
-- same order here.

local splashSprite = love.graphics.newImage('sprites/splash.png')
local splashSprite2 = love.graphics.newImage('sprites/splash2.png')
local font = love.graphics.newFont('fonts/ARCADECLASSIC.TTF', 36)
local playText = love.graphics.newText(font, 'PRESS SPACEBAR TO PLAY')
local titleFont = love.graphics.newFont('fonts/ARCADECLASSIC.TTF', 100)
local title = love.graphics.newText(titleFont, 'PHIL')

function love.load()
  menu = true
  alpha = 255
  breath = true
  fadeTimer = 0
  fadeMax = 1
  canPlay = false
  alpha2 = 255
end

function love.update(dt)
  if not menu then
    Game:update(dt)
    Game:print()
  end
    
  if menu then
    local speed = 300
    if breath then
      alpha = alpha - speed * dt
      if alpha < 20 then
        breath = false
      end
    else
      alpha = alpha + speed * dt
      if alpha >= 254 then
        breath = true
      end
    end
  end
end

function love.draw()
  if menu then
    -- love.graphics.setColor(255,255,255,alpha2)
    love.graphics.draw(splashSprite, 0, 0)
    -- love.graphics.draw(splashSprite2, 0, 0)
    love.graphics.setColor(20, 20, 20, alpha)
    love.graphics.rectangle('fill', 100-20,love.graphics.getHeight()-75, love.graphics.getWidth()-160, 55)
    love.graphics.setColor(255,255,255,alpha)
    love.graphics.draw(playText, 122, love.graphics.getHeight() - 65)
    love.graphics.setColor(255,255,255)
    love.graphics.draw(title, love.graphics.getWidth()-290, 80)
  end
  if not menu then
    Game:draw(true)
  end
end

function love.keypressed(key)
  if not menu then
    Game:keypressed(key)
  end
end

function love.keyreleased(key)
  if key == 'escape' and menu then
    love.event.quit()
  end
  if key == 'space' and menu then
    menu = false
    Game:initialize()
  else
    Game:keyreleased(key)
  end
end

function love.mousepressed(x, y, button)
  if not menu then
    Game:mousepressed(x, y, button)
  end
end
