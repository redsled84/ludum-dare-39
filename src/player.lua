-- utils
local vectorUtils = require 'utils.vectorUtils'

-- constants
local powerDecrement = 0.1
local laserCost = 0.5
local zeroVector = vectorUtils.getZeroVector()
local KEYS = {
  w = false,
  s = false,
  d = false,
  a = false,
}

-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'
local io = require 'io'

-- src
local Timer = require 'src.timer'
-- local Tween = require 'src.tween'

local Player = class('Player')

function Player:initialize(spawnVector)
  self.position = spawnVector
  -- self.tween = Tween:new()
  self.width = tileSize
  self.height = tileSize
  self.item = nil
  self.hasItem = false
  self.dir = 'left'
  self.sprites = {
    up = love.graphics.newImage('sprites/player_up.png'),
    down = love.graphics.newImage('sprites/player_down.png'),
    left = love.graphics.newImage('sprites/player_left.png'),
    right = love.graphics.newImage('sprites/player_right.png'),
    -- run = love.graphics.newImage('sprites/player_run.png'),
    -- crystal = love.graphics.newImage('sprites/crystal.png')
  }
  self.finishedMap = false
  self.velocity = zeroVector
  self.speed = 100
  self.actionKey = false
  self.collider = world:newRectangleCollider(self.position.x, self.position.y, tileSize / 2.2, tileSize / 2.2)
  self.collider:setCollisionClass(self.name)
  self.collider:setFixedRotation(true)
  self.collider:setObject(self)
  self.collider:setPreSolve(function(c1, c2, contact)
    if c1.collision_class == 'Player' and c2.collision_class == 'Crystal' then
      contact:setEnabled(false)
    end
  end)
end

function Player:hasFinishedMap()
  return self.finishedMap
end

function Player:update(dt)
  self:movementWithKeys(dt)
  local x, y = self.collider:getPosition()
  self.position.x = x - tileSize / 2
  self.position.y = y - tileSize / 2
  self:updateCollider(dt)
end

function Player:updateCollider(dt)
  local colliders
  if self.actionKey then
    local x, y = self.collider:getPosition()
    colliders = world:queryCircleArea(x, y, 20, {'Crystal'})
  end
  if colliders then
    local crystal = nil
    for i = 1, #colliders do
      if colliders[i].collision_class == 'Crystal' then
        crystal = colliders[i]
        break
      end
    end
    local cx, cy = crystal:getPosition()
    local px, py = self.collider:getPosition()
    local vx = px - cx
    local vy = py - cy
    crystal:setLinearVelocity(vx * 10, vy * 10)
  end
end

function Player:movementWithKeys()
  self.velocity = zeroVector
  if KEYS['d'] then
    self.velocity.x = self.speed
    self.dir = 'right'
  elseif KEYS['a'] then
    self.velocity.x = -self.speed
    self.dir = 'left'
  elseif not KEYS['a'] and not KEYS['d'] then
    self.velocity.x = 0
  end
  if KEYS['s'] then
    self.velocity.y = self.speed
    self.dir = 'down'
  elseif KEYS['w'] then
    self.velocity.y = -self.speed
    self.dir = 'up'
  elseif not KEYS['w'] and not KEYS['s'] then
    self.velocity.y = 0
  end
  self.collider:setLinearVelocity(self.velocity.x, self.velocity.y)
end

function Player:checkItems(Items)
  for i = 1, #Items do
    local item = Items[i]
    if item.position == self.position and not self.hasItem and not item.pickedUp then
      item.pickedUp = true
      self.hasItem = true
      self.item = item
    end
  end
end

function Player:draw()
  self:drawSprites()
end

function Player:drawSprites()
  local x, y = self.position.x, self.position.y
  love.graphics.setColor(255,255,255)
  -- draw held item
  if self.hasItem then
    love.graphics.draw(self.sprites['crystal'], x, y - 4)
  end
  -- draw player sprite
  love.graphics.draw(self.sprites[self.dir], x, y)
end

function Player:drawDebug(bool)
  if not bool then return end
  local x, y = self.position.x, self.position.y
  love.graphics.setColor(255,120,120)
  love.graphics.rectangle('line', x, y, tileSize, tileSize)
end

function Player:keypressed(key)
  for k, v in pairs(KEYS) do
    if k == key and not v then
      KEYS[k] = true
    end
  end
  if key == 'f' then
    self.actionKey = not self.actionKey
  end
end

function Player:keyreleased(key)
  for k, v in pairs(KEYS) do
    if k == key and v then
      KEYS[k] = false
    end
  end
end

return Player
