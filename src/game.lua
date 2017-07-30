-- constants
tileSize = 32
states = {
  game_start = 'game_start',
  game_over = 'game_over',
  ingame_menu = 'ingame_menu',
  splash_menu = 'splash_menu',
  level_change = 'level_change'
}
local gridWidth = 24
local gridHeight = 24

-- libs
local Cam = require 'libs.camera'
local cam = Cam(0, 0)
local class = require 'libs.middleclass'
local inspect = require 'libs.inspect'
local LightWorld = require 'libs.light_world'
local PostShader = require "libs.light_world.postshader"
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

local function getRandPositionOutsideRange(a, max)
  local attempts = 0
  local maxAttempts = 100
  repeat
    local x, y = math.random(1, Map.gridWidth), math.random(1, Map.gridHeight)
    local val = Map:getGridValue(x, y)
    local dist = math.sqrt((a.x - x)^2 + (a.y - y)^2)
    if val == 0 and dist > max then
      return vector(x, y)
    else
      attempts = attempts + 1
    end
  until attempts >= maxAttempts
  getRandPositionOutsideRange(a, max - 1)
end

function Game:initialize(firstTime)
  lightWorld = LightWorld({
    ambient = {45, 45, 45},
    refractionStrength = 1.0,
    reflectionVisibility = 0.95,
    shadowBlur = 0.0
  })

  lightPlayer = lightWorld:newLight(0, 0, 200, 150, 100, 235)

  lightObjects = {}
  local rogueMap = ROT.Map.Brogue(gridWidth, gridHeight):create(function(x, y, val)
    if val == 1 then
      local lo = lightWorld:newRectangle(y*tileSize + tileSize/2, x*tileSize+4, tileSize, tileSize)
      table.insert(lightObjects, lo)
    end
  end, true)
  Map:initialize(rogueMap, gridWidth, gridHeight)
  -- The spawn vector is based on the map grid position not the actual pixel positions...
  local spawnPosition = getRandomFloorPosition()
  if firstTime then
    Player:initialize(spawnPosition)
  else
    Player.position = spawnPosition
    Player.drawPosition = spawnPosition * tileSize
    Player.finishedMap = false
  end

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

  local stairPosition = getRandPositionOutsideRange(spawnPosition, 10)
  Map:setGridValue(stairPosition.x, stairPosition.y, 4)

  self.Entities = {Player, unpack(self.Items)}
  --print(inspect(Map.Grid))

  -- post_shader = PostShader()
  -- post_shader:toggleEffect("blur", 2.0, 2.0)
  render_buffer = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
end

function Game:update(dt)
  -- Check for behavior first
  Game:checkState()

  if self.state ~= 'game_over' then
    Player:update(dt, Map)
    local camX, camY = Player:getPixelPosition()
    cam:lookAt(camX, camY)
    lightPlayer:setPosition(camX + tileSize / 2, camY + tileSize / 2)
    lightWorld:update(dt)
    local lx, ly = -cam.x + love.graphics.getWidth()/2, -cam.y + love.graphics.getHeight()/2
    lightWorld:setTranslation(lx, ly)
  end
  if self.state == 'level_change' then
    self:initialize(false)
  end
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
  if Player:hasFinishedMap() then
    self.state = 'level_change'
  end
end

function Game:draw(bool)
  if not bool then return end

  if self.state == 'game_start' then
    cam:attach()
    lightWorld:draw(function()
      Map:drawLayer('floor')
      self:drawShadows(true)
      Map:drawLayer('stair')
      Player:drawLaser()
      Map:drawLayer('wall_side')
      self:drawItems(true)
      Player:draw()
      Map:drawLayer('wall_top')
    -- Map:drawLayer('lighting', Player.position)
    end)
    cam:detach()
    -- love.graphics.setCanvas()
    -- post_shader:drawWith(render_buffer)
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
  cam:attach()
  Player:drawDebug(true)
  Map:drawDebug(false)
  cam:detach()
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
