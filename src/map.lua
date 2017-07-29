-- constants
--

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

local zeroVector = vector(0, 0)
function Map:applyEntityPositionsToGrid(entities)
  for i = 1, #entities do
    local entity = entities[i]
    -- Assure that the entity stays within the Map, otherwise there will be indexing errors
    local delta = self:bindPositionToBounds(entity.position)
    entity.position = entity.position + delta
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
    and position.x <= self.gridWidth
    and position.x <= self.gridHeight
end

function Map:drawDebug()
  for y = 1, self.gridHeight do
    for x = 1, self.gridWidth do
      local num = self.Grid[y][x]
      love.graphics.setColor(255, 255, 255, 100)
      love.graphics.rectangle('line', x * tileSize, y * tileSize, tileSize, tileSize)
      love.graphics.setColor(0, 255, 255, 180)
      love.graphics.print(tostring(x), x * tileSize, y * tileSize)
      love.graphics.print(tostring(y), x * tileSize, y * tileSize + 12)

      if num == 2 then
        love.graphics.setColor(150, 0, 150, 255)
        love.graphics.rectangle('fill', x * tileSize, y * tileSize, tileSize, tileSize)
      end
    end
  end
end

return Map