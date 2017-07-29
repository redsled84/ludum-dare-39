-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'

local Crystal = class('Crystal')

function Crystal:initialize(position, strength)
  self.position = position
  self.drawPosition = position * tileSize
  self.strength = strength
  self.sprite = love.graphics.newImage('sprites/crystal.png')
  self.pickedUp = false
end

function Crystal:getPower()
  return self.strength
end

function Crystal:setPower(strength)
  self.strength = strength
end

function Crystal:setPosition(x, y)
  self.position = vector(x, y)
  self.drawPosition = vector(x, y) * tileSize
end

function Crystal:draw()
  if not self.pickedUp then
    love.graphics.setColor(255,255,255)
    local x, y = self.drawPosition.x, self.drawPosition.y
    love.graphics.draw(self.sprite, x, y)
  end
end

return Crystal
