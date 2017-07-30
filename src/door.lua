local class = require 'libs.middleclass'

local Door = class('Door')

function Door:initialize(position, open)
  self.position = position
  self.collider = world:newRectangleCollider(self.position.x, self.position.y, tileSize, tileSize/2)
  self.collider:setType('static')
  self.collider:setCollisionClass('Door')
  self.collider:setObject(self)
  self.sprites = {
    open = love.graphics.newImage('sprites/door_open.png'),
    close = love.graphics.newImage('sprites/door_closed.png'),
  }
  self.open = open or false
  self.collider:setPreSolve(function(c1, c2, contact)
    if c1.collision_class == 'Door' and c2.collision_class == 'Player' then
      contact:setEnabled(not self.open)
    end
  end)
end

function Door:update(dt)
  local x, y = self.collider:getPosition()
  self.position.x = x - tileSize / 2
  self.position.y = y - tileSize / 2
  if self.collider:enter('Player') then
    self.open = true
  end
  if self.collider:exit('Player') then
    self.open = false
  end
end

function Door:draw()
  local x, y = self.position.x, self.position.y
  love.graphics.setColor(255,255,255)
  if self.open then
    love.graphics.draw(self.sprites.open, x, y)
  else
    love.graphics.draw(self.sprites.close, x, y)
  end
end

return Door