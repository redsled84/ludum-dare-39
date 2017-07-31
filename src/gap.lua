
local class = require 'libs.middleclass'

local Gap = class('Gap')

function Gap:initialize(position)
  self.name = 'Gap'
  self.position = position
  self.collider = world:newRectangleCollider(position.x, position.y, tileSize, tileSize)
  self.collider:setCollisionClass('Gap')
  self.collider:setType('static')
  self.collider:setObject(self)
  self.sprite = love.graphics.newImage('sprites/gap.png')
  self.width = tileSize
  self.height = tileSize
end

function Gap:update(dt)
end
function Gap:draw()
  local x, y = self.collider:getPosition()
  x = x - tileSize / 2
  y = y - tileSize / 2
  love.graphics.setColor(255,255,255)
  love.graphics.draw(self.sprite, x, y)
end

return Gap
