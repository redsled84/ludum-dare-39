-- utils
local vectorUtils = require 'utils.vectorUtils'

-- constants
local powerDecrement = 0.1
local laserCost = 0.5
local zeroVector = vectorUtils.getZeroVector()

-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'
local wf = require 'libs.windfield'
local io = require 'io'

-- src
local Timer = require 'src.timer'
-- local Tween = require 'src.tween'

local Player = class('Player')

function Player:initialize(spawnVector)
  self.drawPosition = spawnVector * tileSize
  self.moveDuration = 0.5
  self.position = spawnVector
  self.power = 100
  -- self.tween = Tween:new()
  self.item = nil
  self.hasItem = false
  self.dir = 'left'
  self.sprites = {
    idle = love.graphics.newImage('sprites/player_idle.png'),
    run = love.graphics.newImage('sprites/player_run.png'),
    crystal = love.graphics.newImage('sprites/crystal.png')
  }
  self.laserActive = false
  self.laserEnd = zeroVector
  self.laserGridEnd = zeroVector
  self.laserStart = zeroVector
  self.laserDuration = .3
  self.laserTimer = 0
  self.laserRange = 3
  self.finishedMap = false
end

function Player:addPower(add)
  self.power = self.power + add
end

function Player:removePower(dec)
  self.power = self.power - dec
end

function Player:getPower()
  return self.power
end

function Player:getPixelPosition()
  return self.drawPosition.x, self.drawPosition.y
end

function Player:hasFinishedMap()
  return self.finishedMap
end

function Player:update(dt)
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

-- `tileSize` was declared globally in Game, so we can use it here without defining it in the file
function Player:draw()
  self:drawSprites()
end

function Player:drawSprites()
  local x, y = self.drawPosition.x, self.drawPosition.y
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
  local x, y = self.drawPosition.x, self.drawPosition.y
  love.graphics.setColor(255,120,120)
  love.graphics.rectangle('line', x, y, tileSize, tileSize)
end

function Player:handleKeys(key, Map, Items)
  local delta = vector(0, 0)
  if key == 'w' then -- movement
    delta.y = delta.y - 1
  elseif key == 's' then
    delta.y = delta.y + 1
  elseif key == 'a' then
    delta.x = delta.x - 1
    self.dir = 'left'
  elseif key == 'd' then
    delta.x = delta.x + 1
    self.dir = 'right'
  elseif key == 'f' then -- item use/pickup
    if self.hasItem then
      self:useItem()
    else
      self:checkItems(Items)
    end
    if Map:getGridValue(self.position.x, self.position.y) == 4 then
      self.finishedMap = true
    end
  elseif key == 'e' then -- item drop
    self:dropItem(Map)
  elseif key == 'left' then -- shoot laser
    self:laser(vector(-1, 0), Map)
  elseif key == 'right' then
    self:laser(vector(1, 0), Map)
  elseif key == 'up' then
    self:laser(vector(0, -1), Map)
  elseif key == 'down' then
    self:laser(vector(0, 1), Map)
  end

  if delta ~= vector(0, 0) and not Player:checkNextPosition(delta, Map) then
    self:setPosition(delta)
    -- self.tween:start(tileSize * self.position, tileSize * (self.position + delta), self.moveDuration)
    self:removePower(powerDecrement)
  end
end

function Player:laser(vec_incr, Map)
  -- Map:print()
  cur = self.position
  while Map:getGridValue(cur.x, cur.y) == 0 do
    cur = cur + vec_incr
  end
  Map:setGridValue(cur.x, cur.y, 0)
  Map:applyWalls()
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
    local positions = {
      Map:getGridValue(self.position.x, self.position.y - 1),
      Map:getGridValue(self.position.x, self.position.y + 1),
      Map:getGridValue(self.position.x + 1, self.position.y),
      Map:getGridValue(self.position.x - 1, self.position.y)
    }

    self.item.pickedUp = false
    self.hasItem = false

    for i = 1, #positions do
      local val = positions[i]
      if val == 0 then
        local temp = self.position
        if i == 1 then
          self.item:setPosition(self.position.x, self.position.y - 1)
        elseif i == 2 then
          self.item:setPosition(self.position.x, self.position.y + 1)
        elseif i == 3 then
          self.item:setPosition(self.position.x + 1, self.position.y)
        elseif i == 4 then
          self.item:setPosition(self.position.x - 1, self.position.y)
        end
      end
    end
  end
end

function Player:checkNextPosition(delta, Map)
  local temp = delta + self.position
  local val = Map:getGridValue(temp.x, temp.y)
  return val == 1 or val == 3
end

function Player:setPosition(delta)
  self.position = self.position + delta
  self.drawPosition = self.drawPosition + delta * tileSize
end

return Player
