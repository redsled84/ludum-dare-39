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
    idle = love.graphics.newImage('sprites/player3-1.png'),
    -- run = love.graphics.newImage('sprites/player_run.png'),
    -- crystal = love.graphics.newImage('sprites/crystal.png')
  }
  self.finishedMap = false
  self.collider = world:newCircleCollider(self.position.x, self.position.y, tileSize / 2)
  self.collider:setCollisionClass(self.name)
  self.collider:setFixedRotation(true)
  self.speed = 100
end

function Player:hasFinishedMap()
  return self.finishedMap
end

function Player:update(dt)
  self:movementWithKeys(dt)
  local x, y = self.collider:getPosition()
  self.position.x = x - tileSize / 2
  self.position.y = y - tileSize / 2
end

function Player:movementWithKeys()
  local delta = zeroVector
  if KEYS['d'] then
    delta.x = self.speed
  elseif KEYS['a'] then
    delta.x = -self.speed
  elseif not KEYS['a'] and not KEYS['d'] then
    delta.x = 0
  end
  if KEYS['s'] then
    delta.y = self.speed
  elseif KEYS['w'] then
    delta.y = -self.speed
  elseif not KEYS['w'] and not KEYS['s'] then
    delta.y = 0
  end
  self.collider:setLinearVelocity(delta.x, delta.y)
end

function Player:getGridPosition()
  return (self.position.x - self.position.x % tileSize) / tileSize,
    (self.position.y - self.position.y % tileSize) / tileSize
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
  if self.dir == 'left' then
    love.graphics.draw(self.sprites['idle'], x, y)
  elseif self.dir == 'right' then
    love.graphics.draw(self.sprites['idle'], x + tileSize, y, 0, -1, 1)
  end
end

function Player:drawDebug(bool)
  if not bool then return end
  local x, y = self.position.x, self.position.y
  love.graphics.setColor(255,120,120)
  love.graphics.rectangle('line', x, y, tileSize, tileSize)
end

function Player:keypressed(key, Map, Items)
  for k, v in pairs(KEYS) do
    if k == key and not v then
      KEYS[k] = true
    end
  end
  if key == 'd' then
    self.dir = 'right'
  elseif key == 'a' then
    self.dir = 'left'
  end

  -- if key == 'f' then -- item use/pickup
  --   if self.hasItem then
  --     self:useItem()
  --   else
  --     self:checkItems(Items)
  --   end
  --   local x, y = self:getGridPosition()
  --   if Map:getGridValue(x, y) == 4 then
  --     self.finishedMap = true
  --   end
  -- elseif key == 'e' then -- item drop
  --   self:dropItem(Map)
  -- end
end

function Player:keyreleased(key)
  for k, v in pairs(KEYS) do
    if k == key and v then
      KEYS[k] = false
    end
  end
end

function Player:useItem()
  if self.hasItem then
    self:addPower(self.item:getPower())
    self.item:setPower(0)
    self.item = nil
    self.hasItem = false
  end
end

function Player:dropItem(Map)
  if self.hasItem and self.item.pickedUp then
    local x, y = self:getGridPosition()
    local positions = {
      Map:getGridValue(x, y - 1),
      Map:getGridValue(x, y + 1),
      Map:getGridValue(x + 1, y),
      Map:getGridValue(x - 1, y)
    }

    self.item.pickedUp = false
    self.hasItem = false

    for i = 1, #positions do
      local val = positions[i]
      if val == 0 then
        local temp = zeroVector()
        if i == 1 then
          self.item:setPosition(x, y - 1)
        elseif i == 2 then
          self.item:setPosition(x, y + 1)
        elseif i == 3 then
          self.item:setPosition(x + 1, y)
        elseif i == 4 then
          self.item:setPosition(x - 1, y)
        end
      end
    end
  end
end

return Player
