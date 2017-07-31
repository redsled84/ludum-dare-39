local audioUtils = require 'utils.audioUtils'
local colliderUtils = require 'utils.colliderUtils'

local class = require 'libs.middleclass'

local Door = class('Door')

function Door:initialize(position, open)
  self.name = 'Door'
  self.position = position
  self.collider = world:newRectangleCollider(self.position.x, self.position.y, tileSize, tileSize/2)
  self.collider:setType('static')
  self.collider:setCollisionClass('Door')
  self.collider:setObject(self)
  self.sprites = {
    open = love.graphics.newImage('sprites/door_open.png'),
    close = love.graphics.newImage('sprites/door_closed.png'),
  }
  self.sounds = {
    open = {
      source = love.audio.newSource('audio/door_open.wav', 'static'),
      counter = 0
    },
    close = {
      source = love.audio.newSource('audio/door_close.wav', 'static'),
      counter = 0
    }
  }
  self.open = open or false
  self.terminals = {}
  self.collider:setPreSolve(function(c1, c2, contact)
    if c1.collision_class == 'Door' and c2.collision_class == 'Player' then
      contact:setEnabled(not self.open)
    end
  end)
end

function Door:update(dt)
  self.position = colliderUtils.getPosition(self.collider)
  local terminals = self.terminals
  if terminals then
    local count = 0
    for i = 1, #terminals do
      local terminal = terminals[i]
      if terminal:isOn() then
        count = count + 1
      end
    end
    if count >= #terminals then
      audioUtils.play(self.sounds.open.source, self.open)
      self.open = true
    else
      audioUtils.play(self.sounds.close.source, not self.open)
      self.open = false
    end
  end
end

function Door:draw()
  local x, y = self.position.x, self.position.y
  love.graphics.setColor(255,255,255)
  if self.open then
    love.graphics.draw(self.sprites.open, x, y + 3)
  else
    love.graphics.draw(self.sprites.close, x, y + 3)
  end
end

return Door
