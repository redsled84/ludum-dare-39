-- utils
local vectorUtils = require 'utils.vectorUtils'

-- constants
local zeroVector = vectorUtils.getZeroVector()
local sprites = {
  floor = love.graphics.newImage('sprites/floor_basic.png'),
  top_wall = love.graphics.newImage('sprites/top_wall.png'),
  bottom_wall = love.graphics.newImage('sprites/bottom_wall.png'),
}
local spriteNums = {
  floor = 0,
  wall = 1,
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

  self.backgroundWalls = {}
  self.foregroundWalls = {}

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
        table.insert(self.backgroundWalls, vector(x, y))
      elseif val == 1 and valBelow == 1 then
        table.insert(self.foregroundWalls, vector(x, y))
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
      local offsetY = val == 1 and -11 or 0
      love.graphics.draw(sprites[layerString], position.x, position.y + offsetY)
    end
  end, true)
end

function Map:drawBackgroundWalls()
  -- loop in reverse order
  for i = #self.backgroundWalls, 1, -1 do
    local position = self.backgroundWalls[i] * tileSize
    love.graphics.setColor(255,255,255)
    love.graphics.draw(sprites['bottom_wall'], position.x, position.y - 11)
  end
end

function Map:drawForegroundWalls()
  for i = 1, #self.foregroundWalls do
    local position = self.foregroundWalls[i] * tileSize
    love.graphics.setColor(255,255,255)
    love.graphics.draw(sprites['top_wall'], position.x, position.y - 11)
  end
end

function Map:getGridValue(x, y)
  if x <= 0 or y <= 0 or y > self.gridHeight or x > self.gridWidth then return end
  return self.Grid[y][x]
end

function Map:setGridValue(x, y, val)
  if x <= 0 or y <= 0 or y > self.gridHeight or x > self.gridWidth then return end
  self.Grid[y][x] = val
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
    end
  end
end

return Map
