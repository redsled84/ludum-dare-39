
-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'
local inspect = require 'libs.inspect'

local Projectile = class('Projectile')

local SPEED = 120

function Projectile:initialize(position, velocity, ignoredColliders)
  self.ignored = ignoredColliders
  self.position = position
  self.velocity = velocity
  self.sprite = love.graphics.newImage('sprites/bullet.png')
  self.collider = world:newRectangleCollider(self.position.x, self.position.y, tileSize / 2, tileSize / 2)
  self.collider:setCollisionClass('Projectile')
  self.collider:setLinearVelocity(SPEED * velocity.x, SPEED * velocity.y)
  -- By default, don't collide with anything.
  self.collider:setPreSolve(function(c1, c2, contact)
    contact:setEnabled(false)
  end)
end

function Projectile:shouldIgnore(collider)
  for i = 1, #self.ignored do
    if self.ignored[i] == collider then
      print 'yatta'
      return true
    end
  end
end

function Projectile:update(dt)
  if self.collider:enter('Crystal') then
    -- get collision position
    local collision_data = self.collider:getEnterCollisionData('Crystal')
    if not self:shouldIgnore(collision_data.collider) then
      local x, y = collision_data.collider:getPosition()
      -- create new projectiles at the collision position
      local pos = vector(x, y)
      local v1 = vector(self.velocity.y, self.velocity.x)
      local v2 = -v1
      Projectiles[#Projectiles+1] = Projectile:new(pos, v1, {collision_data.collider})
      Projectiles[#Projectiles+1] = Projectile:new(pos, v2, {collision_data.collider})
      -- destroy collider
      self.collider:destroy()
    end
  end
  if self.collider:enter('Cell') then
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
