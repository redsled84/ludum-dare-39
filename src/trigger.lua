
local class = require 'libs.middleclass'

local Trigger = class('Trigger')

function Trigger:initialize(position, fn)
  self.fn = fn
  self.name = 'Trigger'
  self.position = position
  self.collider = world:newRectangleCollider(position.x, position.y, tileSize, tileSize)
  self.collider:setCollisionClass('Trigger')
  self.collider:setType('static')
  self.collider:setObject(self)
  self.width = tileSize
  self.height = tileSize
  self.collider:setPreSolve(function(c1, c2, contact)
    contact:setEnabled(false)
  end)
end

function Trigger:update(dt)
  if self.collider:enter('Player') then
    self.fn()
    self.collider:destroy()
  end
end

function Trigger:draw()
end

return Trigger
