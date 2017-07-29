-- constants
local movingPowerDecrement = 1
local consumingPowerIncrement = 1

-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'

-- src
--

local Player = class('Player')

function Player:initialize(spawnVector)
  self.position = spawnVector
  self.power = 5
  self.sprite = love.graphics.newImage('sprites/left2-2.png')
end

function Player:addPower(add)
  self.power = self.power + add
end

function Player:removePower(dec)
  self.power = self.power - dec
end

function Player:handleKeys(key)
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

  self.position = self.position + delta
end

-- `tileSize` was declared globally in Game, so we can use it here without defining it in the file
function Player:draw()
  local x, y = self.position.x, self.position.y
  -- TODO: replace with sprites
  love.graphics.setColor(255,255,255)
  love.graphics.draw(self.sprite, x * tileSize, y * tileSize)
end

function Player:drawDebug()
  local x, y = self.position.x, self.position.y
  -- TODO: replace with sprites
  love.graphics.rectangle('line', x * tileSize, y * tileSize, tileSize, tileSize)
end

return Player