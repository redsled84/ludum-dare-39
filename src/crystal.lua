-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'
local wf = require 'libs.windfield'

local Crystal = class('Crystal')

function Crystal:initialize(position, strength)
  self.position = position
  self.strength = strength
  self.sprite = love.graphics.newImage('sprites/crystal.png')
  self.pickedUp = false
  self.collider = world:newCircleCollider(self.position.x, self.position.y, tileSize/3.5)
  self.collider:setCollisionClass('Crystal')
  self.collider:setLinearDamping(8)
end

function Crystal:update(dt)
  local x, y = self.collider:getPosition()
  self.position.x = x - tileSize / 2
  self.position.y = y - tileSize / 2
end

function Crystal:getPower()
  return self.strength
end

function Crystal:setPower(strength)
  self.strength = strength
end

function Crystal:draw()
  if not self.pickedUp then
    love.graphics.setColor(255,20,147, 130)
    local x, y = self.position.x, self.position.y
    love.graphics.draw(self.sprite, x, y)
  end
end

return Crystal
