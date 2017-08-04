
-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'
local inspect = require 'libs.inspect'

local Timer = require 'src.timer'

local Projectile = class('Projectile')

local SPEED = 120

function Projectile:initialize(position, velocity, ignoredColliders)
  self.ignored = ignoredColliders
  self.timers = {}
  self.position = position
  self.velocity = velocity
  self.sprite = love.graphics.newImage('sprites/projectile.png')
  self.collider = world:newRectangleCollider(self.position.x, self.position.y, tileSize / 3.5, tileSize / 3.5)
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
      return true
    end
  end
end

function Projectile:update(dt, Projectiles)
  if self.collider:enter('Crystal') then
    -- get collision position
    local collision_data = self.collider:getEnterCollisionData('Crystal')
    if not self:shouldIgnore(collision_data.collider) and not collision_data.collider:getObject().pickedUp then
      local x, y = collision_data.collider:getPosition()
      -- create new projectiles at the collision position
      local pos = vector(x, y)
      local v1 = vector(self.velocity.y, self.velocity.x)
      local v2 = -v1
      table.insert(Projectiles, Projectile:new(pos, v1, {collision_data.collider}))
      table.insert(Projectiles, Projectile:new(pos, v2, {collision_data.collider}))
      -- destroy collider
      self.collider:destroy()
    end
  end
  if self.collider:enter('Terminal') then
    local collision_data = self.collider:getEnterCollisionData('Terminal')
    local term = collision_data.collider:getObject()
    if not term.hasCrystal then
      term:turnOnTemp()
    end
    self.collider:destroy()
  end
  if self.collider:enter('Cell') then
    self.collider:destroy()
  end
  if self.collider:enter('Door') then
    local collision_data = self.collider:getEnterCollisionData('Door')
    local door = collision_data.collider:getObject()
    if not door.open then
      self.collider:destroy()
    end
  end

end

function Projectile:draw()
  if not self.collider:isDestroyed() then
    local x, y = self.collider:getPosition()
    x = x - tileSize / 2
    y = y - tileSize / 2
    love.graphics.draw(self.sprite, x, y)
  end
end

return Projectile
