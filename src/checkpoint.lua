
local class = require 'libs.middleclass'

local Checkpoint = class('Checkpoint')

function Checkpoint:initialize(position)
  self.name = 'Checkpoint'
  self.position = position
  self.collider = world:newRectangleCollider(position.x, position.y, tileSize, tileSize)
  self.collider:setCollisionClass('Checkpoint')
  self.collider:setType('static')
  self.collider:setObject(self)
  self.width = tileSize
  self.height = tileSize
  self.collider:setPreSolve(function(c1, c2, contact)
    contact:setEnabled(false)
  end)
end

return Checkpoint
