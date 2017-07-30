-- utils
local vectorUtils = require 'utils.vectorUtils'

-- constants
local zeroVector = vectorUtils.getZeroVector()
local sprites = {
  floor = love.graphics.newImage('sprites/floor_basic.png'),
  wall_top = love.graphics.newImage('sprites/wall_top.png'),
  wall_side = love.graphics.newImage('sprites/wall_side.png'),
  stair = love.graphics.newImage('sprites/stairs.png')
}
local spriteNums = {
  floor = 0,
  wall_top = 1,
  wall_side = 3,
  stair = 4,
}

-- libs
local class = require 'libs.middleclass'
local ml = require 'libs.ml'
local vector = require 'libs.vector'

-- src
--

local Map = class('Map')

function Map:initialize(dungeon, gridWidth, gridHeight)
  self.Grid = dungeon._map
  self.gridWidth = gridWidth
  self.gridHeight = gridHeight

  for y = 1, gridHeight do
    local row = dungeon._map[y]
    for x = 1, gridWidth do
      local val = dungeon._map[y][x]
      local valBelow
      if y == gridHeight then
        valBelow = val
      else
        valBelow = dungeon._map[y+1][x]
      end
      if val == 1 and (valBelow == 0 or valBelow == 2) then
        self.Grid[y][x] = 3
      end
    end
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

function Map:drawLayer(layerString)
  self:loopGrid(function(x, y, val)
    local position = vector(x * tileSize, y * tileSize)
    love.graphics.setColor(255,255,255)
    if val == spriteNums[layerString] then
      local offsetY = (val == 3 or val == 1) and -11 or 0
      if val == spriteNums['stair'] then
        love.graphics.draw(sprites['floor'], position.x, position.y)
      end
      love.graphics.draw(sprites[layerString], position.x, position.y + offsetY)
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
