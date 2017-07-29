-- utils
local vectorUtils = require 'utils.vectorUtils'

-- constants
local powerDecrement = .01
local zeroVector = vectorUtils.getZeroVector()

-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'
local wf = require 'libs.windfield'

-- src
local Tween = require 'src.tween'

local Player = class('Player')

function Player:initialize(spawnVector)
  self.drawPosition = spawnVector * tileSize
  self.moveDuration = 0.05
  self.position = spawnVector
  self.power = 20
  self.sprite = love.graphics.newImage('sprites/left2-2.png')
  self.tween = Tween:new()
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

function Player:update(dt)
  Player:updateTween(dt)  
end

function Player:updateTween(dt)
  if self.tween:inProgress() then
    self.tween:update(dt)
    self.drawPosition = self.tween:position()
  end
end

-- `tileSize` was declared globally in Game, so we can use it here without defining it in the file
function Player:draw()
  local x, y = self.drawPosition.x, self.drawPosition.y
  -- TODO: replace with sprites
  love.graphics.setColor(255,255,255)
  -- TODO: use variable for height to subtract
  love.graphics.draw(self.sprite, x, y - 16)
end

function Player:drawDebug(bool)
  if not bool then return end 
  local x, y = self.drawPosition.x, self.drawPosition.y
  love.graphics.setColor(255,120,120)
  love.graphics.rectangle('line', x, y, tileSize, tileSize)
end

function Player:handleKeys(key, Map)
  if self.tween:inProgress() then return end

  local delta = vector(0, 0)
  if key == 'w' then
    delta.y = delta.y - 1
  elseif key == 's' then
    delta.y = delta.y + 1
  elseif key == 'a' then
    delta.x = delta.x - 1
  elseif key == 'd' then
    delta.x = delta.x + 1
  end

  if delta ~= vector(0, 0) and not Player:checkNextPosition(delta, Map) then
    self.tween:start(tileSize * self.position, tileSize * (self.position + delta), self.moveDuration)
    self.position = self.position + delta
    self:removePower(powerDecrement)
  end
end

function Player:checkNextPosition(delta, Map)
  local temp = delta + self.position
  local val = Map:getGridValue(temp.x, temp.y)
  return val == 1
end

return Player
