local colliderUtils = require 'utils.colliderUtils'

local class = require 'libs.middleclass'

local Terminal = class('Terminal')

function Terminal:initialize(position)
  self.name = 'Terminal'
  self.position = position
  local shave = 5
  self.collider = world:newRectangleCollider(position.x + shave / 2, position.y + shave / 2,
    tileSize - shave, tileSize - shave)
  self.collider:setType('static')
  self.collider:setCollisionClass('Terminal')
  self.sprite = love.graphics.newImage('sprites/terminal.png')
  self.hasCrystal = false
  self.collider:setObject(self)
  print(self.position)
end

function Terminal:update(dt)
  -- self.position = colliderUtils.getPosition(self.collider)
  if self.collider:enter('Crystal') then
    self.hasCrystal = true
  end
  if self.collider:exit('Crystal') then
    self.hasCrystal = false
  end
end

function Terminal:draw()
  love.graphics.draw(self.sprite, self.position.x, self.position.y)
end

return Terminal