-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'
local wf = require 'libs.windfield'

-- utils
local colliderUtils = require 'utils.colliderUtils'

local Crystal = class('Crystal')

function Crystal:initialize(position, strength)
  self.name = 'Crystal'
  self.position = position
  self.strength = strength
  self.sprite = love.graphics.newImage('sprites/crystal.png')
  self.pickedUp = false
  self.collider = world:newRectangleCollider(self.position.x, self.position.y, tileSize/3.5, tileSize/3.5)
  self.collider:setCollisionClass('Crystal')
  self.collider:setLinearDamping(10)
  self.collider:setObject(self)
  self.collider:setPreSolve(function(c1, c2, contact)
    contact:setEnabled(false)
  end)
end

function Crystal:update(dt, terminals)
  self.position = colliderUtils.getPosition(self.collider)
  if not self.pickedUp then
    local x, y = self.collider:getPosition()

    if terminals then
      local term
      for i = 1, #terminals do
        local terminal = terminals[i]
        local tx, ty = terminal.collider:getPosition()
        local dist = math.sqrt((tx - x)^2 + (ty-y)^2)
        if dist < 16 and not terminal.hasKey then
          term = terminal
        end
      end
      if term then
        local x, y = term.collider:getPosition()
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
  love.graphics.setColor(255,255,255, 255)
end

return Crystal
