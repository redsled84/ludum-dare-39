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

-- function Map:applyEntityPositionsToGrid(entities)
--   for i = 1, #entites do
    
--   end
-- end

function Map:drawDebug()
  love.graphics.setColor(255,255,255)

  for y = 1, self.gridHeight do
    for x = 1, self.gridWidth do
      love.graphics.rectangle('line', x * tileSize, y * tileSize, tileSize)
      local pos = tostring(x) .. ', ' .. tostring(y)
      love.graphics.print(pos, tileSize, tileSize)
    end
  end
end

return Map