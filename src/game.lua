-- constants
tileSize = 32
states = {
  game_start = 'game_start',
  game_over = 'game_over',
  ingame_menu = 'ingame_menu',
  splash_menu = 'splash_menu',
  level_change = 'level_change'
}
local gridWidth = 18
local gridHeight = 18

-- libs
local Cam = require 'libs.camera'
local cam = Cam(0, 0)
local class = require 'libs.middleclass'
local inspect = require 'libs.inspect'
local ROT = require 'libs.rotLove.rot'
local vector = require 'libs.vector'

-- TODO: implement animations
-- src
local Crystal = require 'src.crystal'
local HUD = require 'src.hud'
local Map = require 'src.map'
local Player = require 'src.player'

local Game = class('Game')

local function getRandomFloorPosition()
  local attempts = 0
  local maxAttempts = 100
  repeat
    local x, y = math.random(1, Map.gridWidth), math.random(1, Map.gridHeight)
    local val = Map:getGridValue(x, y)
    if val == 0 then
      return vector(x, y) 
    else
      attempts = attempts + 1
    end
  until attempts >= maxAttempts
end

function Game:initialize()
  local rogueMap = ROT.Map.Brogue(gridWidth, gridHeight):create()
  Map:initialize(rogueMap, gridWidth, gridHeight)
  -- The spawn vector is based on the map grid position not the actual pixel positions...
  local spawnPosition = getRandomFloorPosition()
  Player:initialize(spawnPosition)

  -- This will be a general purpose table for *referencing* entities such as items, player,
  -- enemies, walls. Each entity requires a position vector.
  self.Items = {}
  self.state = 'game_start'

  local nCrystals = math.random(1, 3)
  for i = 1, nCrystals do
    local position = getRandomFloorPosition()
    local strength = 8
    table.insert(self.Items, Crystal:new(position, strength))
  end

  self.Entities = {Player, unpack(self.Items)}
end

function Game:update(dt)
  -- Check for behavior first
  Game:checkState()

  if self.state ~= 'game_over' then
    Player:update(dt, Map)
    local camX, camY = Player:getPixelPosition()
    cam:lookAt(camX, camY)
  end
  Map:updateWalls()
  Map:bindEntitiesToGrid(self.Entities)

  -- Then update the turns
end

function Game:print()
  -- print(Player.laserActive)
end

function Game:checkState()
  if Player:getPower() <= 0 then
    self.state = 'game_over'
  end
end

function Game:draw(bool)
  if not bool then return end

  if self.state == 'game_start' then
    cam:attach()
    Map:drawLayer('floor')
    self:drawShadows(true)
    Player:drawLaser()
    Map:drawBackgroundWalls()
    self:drawItems(true)
    Player:draw()
    Map:drawForegroundWalls()
    cam:detach()
    HUD:draw(Player)
  elseif self.state == 'game_over' then
    -- TODO: change game over screen with player dying animation and restarting game
    love.graphics.setColor(255,0,0)
    love.graphics.print('You Ran Out Of Power!',
      love.graphics.getWidth() / 2 - 16, love.graphics.getHeight() / 2)
  end
  self:drawDebug(true)
end

function Game:drawItems(bool)
  if not bool then return end
  for i = 1, #self.Items do
    local item = self.Items[i]
    item:draw()
  end
end

function Game:drawShadows(bool)
  for i = 1, #self.Entities do
    local entity = self.Entities[i]
    if not entity.pickedUp then
      love.graphics.setColor(10, 10, 10, 100)
      local x, y = entity.drawPosition.x, entity.drawPosition.y
      love.graphics.ellipse('fill', x + tileSize / 2, y + tileSize - 4, 18, 6)
    end
  end
end

function Game:drawDebug(bool)
  if not bool and self.state ~= 'game_over' then return end
  Player:drawDebug(true)
  Map:drawDebug(true)
end

function Game:keypressed(key)
  if key == 'escape' then
    love.event.quit('restart')
  end
  if key == 'q' then
    love.event.quit()
  end

  Player:handleKeys(key, Map, self.Items)
end

function Game:mousepressed(x, y, button)
  -- replace with checking menu buttons
end

return Game
