-- utils
local vectorUtils = require 'utils.vectorUtils'

-- constants
local zeroVector = vectorUtils.getZeroVector()
local sprites = {
  floor = love.graphics.newImage('sprites/floor.png'),
  wall = love.graphics.newImage('sprites/wall.png'),
}
for k, v in pairs(sprites) do
  sprites[k]:setFilter('nearest', 'nearest')
end

local spriteNums = {
  floor = 0,
  wall = 1,
  crystal = 2,
}

-- libs
local class = require 'libs.middleclass'
local io = require 'io'
local vector = require 'libs.vector'

-- src
--

local Map = class('Map')

function Map:initialize(map, gridWidth, gridHeight)
  self.Grid = map
  self.gridWidth = gridWidth
  self.gridHeight = gridHeight

  -- first number is the alpha
  -- second number is the distance to go past for the alpha
  self.lightingThresholds = {
    vector(255, 1),
    vector(180, 1.5),
    vector(45, 2.5),
    vector(10, 4)
  }
  -- self:applyWalls()
end

-- function Map:applyWalls()
--   for y = 1, self.gridHeight do
--     local row = self.Grid[y]
--     for x = 1, self.gridWidth do
--       local val = self.Grid[y][x]
--       local valBelow
--       if y == gridHeight then
--         valBelow = val
--       else
--         valBelow = not self:safeCheck(x, y + 1) and self.Grid[y+1][x] or self.Grid[y][x]
--       end
--       if val == 1 and (valBelow == 0 or valBelow == 2) then
--         self.Grid[y][x] = 3
--       end
--     end
--   end
-- end

function Map:print()
  for x = 1, self.gridWidth do
    for y = 1, self.gridHeight do
      io.write(self.Grid[y][x])
    end
    io.write('\n')
  end
end

function Map:initializeEmptyGrid()
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
      temp[#temp+1] = 0
    end
    table.insert(self.Grid, temp)
  end
end

function Map:entityIsInsideBounds(position)
  return position.x >= 1
    and position.y >= 1
    and position.x < self.gridWidth
    and position.y < self.gridHeight
end

function Map:drawLayer(layerString, playerPos)
  self:loopGrid(function(x, y, val)
    local position = vector(x * tileSize, y * tileSize)
    if val ~= 0 then
      love.graphics.setColor(225, 179, 155)
      love.graphics.draw(sprites['floor'], position.x, position.y)
    end
    if val == spriteNums[layerString] then
      if val == 0 then
        love.graphics.setColor(225, 179, 155)
      else
        love.graphics.setColor(255,255,255)
      end
      love.graphics.draw(sprites[layerString], position.x, position.y)
    end
  end, true)
end

function Map:getGridValue(x, y)
  if self:safeCheck(x, y) then return end
  return self.Grid[y][x]
end

function Map:setGridValue(x, y, val)
  if self:safeCheck(x, y) then return end
  self.Grid[y][x] = val
end

function Map:safeCheck(x, y)
  return x <= 0 or y <= 0 or y > self.gridHeight or x > self.gridWidth
end

function Map:loopGrid(f, continue)
  local continue = continue or true
  for y = 1, self.gridHeight do
    for x = 1, self.gridWidth do
      if not continue then break end
      local val = Map:getGridValue(x, y)
      f(x, y, val)
    end
  end
end

function Map:drawDebug(bool)
  if not bool then return end
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
      love.graphics.setColor(255,0,0,120)
      love.graphics.print(tostring(num), position.x + 18, position.y)
    end
  end
end

return Map
