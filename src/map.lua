-- utils
local vectorUtils = require 'utils.vectorUtils'

-- constants
local zeroVector = vectorUtils.getZeroVector()

-- libs
local class = require 'libs.middleclass'
local ml = require 'libs.ml'
local vector = require 'libs.vector'

-- src
--

local Map = class('Map')

function Map:initialize(gridWidth, gridHeight)
  self.Grid = {}
  self.gridWidth = gridWidth
  self.gridHeight = gridHeight

  self:initializeGrid()
end

function Map:initializeGrid()
  -- Initialize an empty grid
  -- Our grid will look something like this:
  --  {
  --    {1, 1, 1, 1, 1, ...},
  --    {1, 0, 0, 0, 0, ...},
  --    {1, 0, 0, 0, 0, ...},
  --    ...
  --  }
  for y = 1, self.gridHeight do
    local temp = {}
    for x = 1, self.gridWidth do
      ml.extend(temp, {0})
    end
    ml.extend(self.Grid, {temp})
  end
end

function Map:bindEntitiesToGrid(entities)
  for i = 1, #entities do
    local entity = entities[i]
    -- Assure that the entity stays within the Map, otherwise there will be indexing errors
    local deltaPos = self:bindPositionToBounds(entity.position)
    local deltaDrawPos = self:bindPositionToBounds(entity.drawPosition / tileSize)
    
    entity.position = entity.position + deltaPos
    entity.drawPosition = entity.drawPosition + deltaDrawPos
  end
end

function Map:bindPositionToBounds(position)
  local delta = vector(0, 0)
  if not self:entityIsInsideBounds(position) then
    if position.x < 1 then
      delta.x = 1
    elseif position.x > self.gridWidth then
      delta.x = -1
    end
    if position.y < 1 then
      delta.y = 1
    elseif position.y > self.gridHeight then
      delta.y = -1
    end
  end

  return delta
end

function Map:entityIsInsideBounds(position)
  return position.x >= 1
    and position.y >= 1
    and position.x < self.gridWidth
    and position.y < self.gridHeight
end

function Map:drawDebug()
  self:drawMapDebug()
  self:drawGridDebug('fill')
end

function Map:drawMapDebug()
  love.graphics.setColor(35, 120, 255)
  love.graphics.rectangle('line', tileSize, tileSize,
    self.gridWidth * tileSize, self.gridHeight * tileSize)
end

function Map:drawGridDebug(drawType)
  for y = 1, self.gridHeight do
    for x = 1, self.gridWidth do
      local num = self.Grid[y][x]
      local position = vector(x * tileSize, y * tileSize)

      love.graphics.setColor(255, 255, 255, 45)
      love.graphics.rectangle(drawType, position.x, position.y, tileSize, tileSize)
      love.graphics.setColor(255, 255, 60, 120)
      love.graphics.print(tostring(x), position.x, position.y)
      love.graphics.print(tostring(y), position.x, position.y + 12)
    end
  end
end

return Map