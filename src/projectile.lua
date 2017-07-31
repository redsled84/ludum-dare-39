
-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'
local wf = require 'libs.windfield'
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
end

function Projectile:update(dt)
  local x, y = self.collider:getPosition()
  self.position.x = x - tileSize / 2
  self.position.y = y - tileSize / 2
end

function Projectile:draw()
  local x, y = self.position.x, self.position.y
  love.graphics.draw(self.sprite, x, y)
end

return Projectile
