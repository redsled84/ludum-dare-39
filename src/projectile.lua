
-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'
local inspect = require 'libs.inspect'

local Projectile = class('Projectile')

local SPEED = 120

function Projectile:initialize(position, velocity)
  self.position = position
  self.velocity = velocity
  self.sprite = love.graphics.newImage('sprites/bullet.png')
  self.collider = world:newRectangleCollider(self.position.x, self.position.y, tileSize / 3.5, tileSize / 3.5)
  self.collider:setCollisionClass('Projectile')
  self.collider:setLinearVelocity(SPEED * velocity.x, SPEED * velocity.y)
  -- By default, don't collide with anything.
  self.collider:setPreSolve(function(c1, c2, contact)
    contact:setEnabled(false)
  end)
end

function Projectile:update(dt)
  if self.collider:enter('Crystal') then
    print('crystal!')
    self.collider:destroy()
  end
  if self.collider:enter('Cell') then
    print('crystal!')
    self.collider:destroy()
  end
  if not self.collider:isDestroyed() then
    local x, y = self.collider:getPosition()
    self.position.x = x - tileSize / 2
    self.position.y = y - tileSize / 2
  end
end

function Projectile:draw()
  local x, y = self.position.x, self.position.y
  love.graphics.draw(self.sprite, x, y)
end

return Projectile
