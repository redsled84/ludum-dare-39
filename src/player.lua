-- constants
local movingPowerDecrement = 1
local consumingPowerIncrement = 1

-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'

-- src
local Tween = require 'src.tween'
--

local Player = class('Player')

function Player:initialize(spawnVector)
  self.position = spawnVector
  self.drawPosition = spawnVector * tileSize
  self.moveDuration = 0.05
  self.tween = Tween:new()
  self.power = 5
  self.sprite = love.graphics.newImage('sprites/left2-2.png')
end

function Player:addPower(add)
  self.power = self.power + add
end

function Player:removePower(dec)
  self.power = self.power - dec
end

function Player:update(dt)
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

function Player:drawDebug()
  local x, y = self.drawPosition.x, self.drawPosition.y
  -- TODO: replace with sprites
  love.graphics.rectangle('line', x, y, tileSize, tileSize)
end

function Player:handleKeys(key)
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

  if key == 'w' or key == 's' or key == 'a' or key == 'd' then
    self:removePower(movingPowerDecrement)
  end

  if delta ~= vector(0, 0) then
      print(delta)
      self.tween:start(tileSize * self.position, tileSize * (self.position + delta), self.moveDuration)
  end

  self.position = self.position + delta
end

return Player
