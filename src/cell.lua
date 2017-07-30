local class = require 'libs.middleclass'

local Cell = class('Cell')

function Cell:initialize(position)
  print(position)
  self.position = position
  self.collider = world:newRectangleCollider(position.x, position.y, tileSize, tileSize)
  self.collider:setCollisionClass('Cell')
  self.collider:setType('static')
  self.width = tileSize
  self.height = tileSize
end

return Cell