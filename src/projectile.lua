
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
  self.collider:setPostSolve(function(c1, c2, contact)
    if c1.collision_class == 'Projectile' and c2.collision_class ~= 'Player' then
      self.collider:destroy()
    end
  end)
end

function Projectile:update(dt)
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
