-- constants
--

-- libs
local class = require 'libs.middleclass'
local ml = require 'libs.ml'

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

function Map:applyEntityPositionsToGrid(entities)
  for i = 1, #entities do
    local entity = entities[i]

  end
end

function Map:drawDebug()
  for y = 1, self.gridHeight do
    for x = 1, self.gridWidth do
      love.graphics.setColor(255, 255, 255, 100)
      love.graphics.rectangle('line', (x - 1) * tileSize, (y - 1) * tileSize, tileSize, tileSize)
      love.graphics.setColor(0, 255, 255, 180)
      love.graphics.print(tostring(x), (x - 1) * tileSize, (y - 1) * tileSize)
      love.graphics.print(tostring(y), (x - 1) * tileSize, (y - 1) * tileSize + 12)
    end
  end
end

return Map