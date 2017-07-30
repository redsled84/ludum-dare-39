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

-- src
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
    idle = love.graphics.newImage('sprites/stand.png'),
    run = love.graphics.newImage('sprites/run.png')
  }
  self.laserActive = false
  self.laserEnd = zeroVector
  self.laserGridEnd = zeroVector
  self.laserStart = zeroVector
  self.laserDuration = .3
  self.laserTimer = 0
  self.laserRange = 3
  self.animationDuration = 0.1
  self.animationTimer = 0
  self.startAnimation = false
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

function Player:update(dt, Map)
  self:updateAnimationTimer(dt)
  self:updateLaserTimer(dt, Map)
  -- Player:updateTween(dt)
end

-- Replace with modular timers
function Player:updateAnimationTimer(dt)
  if self.startAnimation then
    if self.animationTimer < self.animationDuration then
      self.animationTimer = self.animationTimer + dt
    else
      self.animationTimer = 0
      self.startAnimation = false
    end
  end
end

function Player:updateLaserTimer(dt, Map)
  if self.laserActive then
    if self.laserTimer < self.laserDuration then
      self.laserTimer = self.laserTimer + dt
    else
      self.laserTimer = 0
      self.laserActive = false
    end
  end
end

function Player:updateTween(dt)
  if self.tween:inProgress() then
    self.tween:update(dt)
    self.drawPosition = self.tween:position()
  end
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

function Player:drawLaser()
  if self.laserActive then
    love.graphics.setColor(255,0,0,100)
    -- local x1 = self.position.x * tileSize + tileSize / 2
    -- local y1 = self.position.y * tileSize + 18
    -- local x2 = self.laserEnd.x * tileSize + tileSize / 2
    -- local y2 = self.laserEnd.y * tileSize + 18
    local x1 = self.position.x * tileSize + tileSize / 2
    local y1 = self.position.y * tileSize + tileSize / 2
    local x2 = self.laserEnd.x * tileSize + tileSize / 2
    local y2 = self.laserEnd.y * tileSize + tileSize / 2
    love.graphics.line(x1, y1, x2, y2)
  end
end

function Player:drawSprites()
  local x, y = self.drawPosition.x, self.drawPosition.y
  love.graphics.setColor(255,255,255)
  -- TODO: use variable for height to subtract
  if self.animationTimer == 0 then
    if self.dir == 'left' then
      love.graphics.draw(self.sprites['idle'], x, y)
    elseif self.dir == 'right' then
      love.graphics.draw(self.sprites['idle'], x + tileSize, y, 0, -1, 1)
    end
  else
    if self.dir == 'left' then
      love.graphics.draw(self.sprites['run'], x, y)
    elseif self.dir == 'right' then
      love.graphics.draw(self.sprites['run'], x + tileSize, y, 0, -1, 1)
    end
  end
end

function Player:drawDebug(bool)
  if not bool then return end 
  local x, y = self.drawPosition.x, self.drawPosition.y
  love.graphics.setColor(255,120,120)
  love.graphics.rectangle('line', x, y, tileSize, tileSize)
end

function Player:handleKeys(key, Map, Items)
  -- if self.tween:inProgress() then return end
  local delta = vector(0, 0)
  if not self.laserActive and not self.startAnimation then
    -- TODO: break up movement and item keys into seperate functions
    if key == 'w' then
      delta.y = delta.y - 1
    elseif key == 's' then
      delta.y = delta.y + 1
    elseif key == 'a' then
      delta.x = delta.x - 1
      self.dir = 'left'
    elseif key == 'd' then
      delta.x = delta.x + 1
      self.dir = 'right'
    elseif key == 'f' then
      if self.hasItem then
        self:useItem()
      else
        self:checkItems(Items)
      end
    elseif key == 'e' then
      self:dropItem(Map)
    end
    self:shootLaser(key, Map)
  end

  if delta ~= vector(0, 0) and not Player:checkNextPosition(delta, Map) then
    if self.startAnimation then
      self.animationTimer = 0
    else
      self.startAnimation = true
    end
    self:setPosition(delta)
    -- self.tween:start(tileSize * self.position, tileSize * (self.position + delta), self.moveDuration)
    self:removePower(powerDecrement)
  end
end

function Player:shootLaser(key, Map)
  if key == 'up' or key == 'down' or key == 'left' or key == 'right' then
    self:removePower(laserCost)
  end
  if key == 'up' and not Map:safeCheck(self.position.x, self.position.y - 1) then
    self.laserActive = true
    self.laserStart = vector(self.position.x, self.position.y)
    self.laserEnd = vector(self.laserStart.x, self.laserStart.y)
    for i = -1, -self.laserRange, -1 do
      local y = self.laserEnd.y + i
      if y < 1 then
        y = 1
      end
      self.laserEnd.y = y
      if Map:getGridValue(self.position.x, y) == 1 then
        break
      end
    end
    if self.laserStart ~= self.laserEnd then
      self.laserActive = true
    end
  elseif key == 'down' and not Map:safeCheck(self.position.x, self.position.y + 1) then
    self.laserActive = true
    self.laserStart = vector(self.position.x, self.position.y)
    self.laserEnd = vector(self.laserStart.x, self.laserStart.y)
    for i = 0, self.laserRange do
      local y = self.laserEnd.y + i
      if y > Map.gridHeight then
        y = Map.gridHeight
      end
      self.laserEnd.y = y
      if Map:getGridValue(self.position.x, y) == 1 then
        break
      end
    end
    if self.laserStart ~= self.laserEnd then
      self.laserActive = true
    end
  elseif key == 'right' and not Map:safeCheck(self.position.x + 1, self.position.y) then
    self.laserActive = true
    self.laserStart = vector(self.position.x, self.position.y)
    self.laserEnd = vector(self.laserStart.x, self.laserStart.y)
    for i = 0, self.laserRange do
      local x = self.laserEnd.x + i
      if x > Map.gridWidth then
        x = Map.gridWidth
      end
      self.laserEnd.x = x
      if Map:getGridValue(x, self.position.y) == 1 then
        break
      end
    end
    if self.laserStart ~= self.laserEnd then
      self.laserActive = true
    end
    self.dir = 'right'
  elseif key == 'left' and not Map:safeCheck(self.position.x - 1, self.position.y) then
    self.laserStart = vector(self.position.x, self.position.y)
    self.laserEnd = vector(self.laserStart.x, self.laserStart.y)
    for i = -1, -self.laserRange, -1 do
      local x = self.laserEnd.x + i
      if x < 1 then
        x = 1
      end
      self.laserEnd.x = x
      if Map:getGridValue(x, self.position.y) == 1 then
        break
      end
    end
    if self.laserStart ~= self.laserEnd then
      self.laserActive = true
    end
    self.dir = 'left'
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
  return val == 1
end

function Player:setPosition(delta)
  self.position = self.position + delta
  self.drawPosition = self.drawPosition + delta * tileSize
end

return Player
