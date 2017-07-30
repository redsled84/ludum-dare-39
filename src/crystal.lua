-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'
local wf = require 'libs.windfield'

-- utils
local colliderUtils = require 'utils.colliderUtils'

local Crystal = class('Crystal')

function Crystal:initialize(position, strength)
  self.position = position
  self.strength = strength
  self.sprite = love.graphics.newImage('sprites/crystal.png')
  self.pickedUp = false
  self.collider = world:newRectangleCollider(self.position.x, self.position.y, tileSize/3.5, tileSize/3.5)
  self.collider:setCollisionClass('Crystal')
  self.collider:setLinearDamping(10)
  self.collider:setObject(self)
  self.collider:setPreSolve(function(c1, c2, contact)
    if c1.collision_class == 'Crystal' and (c2.collision_class == 'Player' or c2.collision_class == 'Terminal') then
      contact:setEnabled(false)
    end
  end)
end

function Crystal:update(dt)
  self.position = colliderUtils.getPosition(self.collider)
  if not self.pickedUp then
    local x, y = self.collider:getPosition()
    colliders = world:queryRectangleArea(x, y, 15, 15, {'Terminal'})
    if colliders then
      local terminal
      for i = 1, #colliders do
        local collider = colliders[i]
        local colliderObject = collider:getObject()
        if colliderObject then
          if not colliderObject.hasCrystal then
            terminal = collider
          end
        end
      end    
      if terminal then
        local x, y = terminal:getPosition()
        self.collider:setPosition(x, y)
      end
    end
  end
  if self.collider:exit('Player') then
    self.pickedUp = false
  end
end

function Crystal:getPower()
  return self.strength
end

function Crystal:setPower(strength)
  self.strength = strength
end

function Crystal:draw()
  love.graphics.setColor(255,255,255, 160)
  local x, y = self.position.x, self.position.y
  love.graphics.draw(self.sprite, x, y)
end

return Crystal
