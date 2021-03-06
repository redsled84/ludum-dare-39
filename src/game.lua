-- constants
tileSize = 16
states = {
  game_start = 'game_start',
  game_over = 'game_over',
  ingame_menu = 'ingame_menu',
  splash_menu = 'splash_menu',
  level_change = 'level_change'
}

local gameUtils = require 'utils.gameUtils'

-- libs
local Cam = require 'libs.camera'
local cam = Cam(0, 0)
local class = require 'libs.middleclass'
local inspect = require 'libs.inspect'
local LightWorld = require 'libs.light_world'
local PostShader = require "libs.light_world.postshader"
local vector = require 'libs.vector'
local wf = require 'libs.windfield'
world = wf.newWorld(0, 0, true)
world:addCollisionClass('Cell')
world:addCollisionClass('Crystal')
world:addCollisionClass('Door')
world:addCollisionClass('Gap')
world:addCollisionClass('Player')
world:addCollisionClass('Terminal')
world:addCollisionClass('Checkpoint')
world:addCollisionClass('Trigger')
world:addCollisionClass('Projectile', {ignore={'Player'}})
local controlsFont = love.graphics.newFont('fonts/ARCADECLASSIC.TTF', 26)
controlsFont:setFilter('nearest', 'nearest')

-- TODO: implement animations
-- src
local Cell = require 'src.cell'
local Crystal = require 'src.crystal'
local Door = require 'src.door'

local Map = require 'src.map'
local Player = require 'src.player'
local Terminal = require 'src.terminal'
local Levels = require 'src.levels2'
local Gap = require 'src.gap'
local Pause = require 'src.pause'
local Checkpoint = require 'src.checkpoint'
local Trigger = require 'src.trigger'

local Game = class('Game')

function Game:initialize()
  gameUtils.initialize()

  -- GAME_POWER = 10
  end_screen = love.graphics.newImage('sprites/fin.png')

  main_theme = love.audio.newSource('audio/main_theme.wav', 'stream')
  main_theme:setLooping(true)
  main_theme:setVolume(.3)
  main_theme:play()

  love.graphics.setDefaultFilter('nearest', 'nearest')
  lightRange = 150
  lightSmooth = 1.0

  lightWorld = LightWorld({
    ambient = {15,15,15},
    refractionStrength = 16.0,
    reflectionVisibility = 1.0,
    shadowBlur = 2.0,
    w = love.graphics.getWidth() / 4,
    h = love.graphics.getHeight() / 4
  })

  self.Lights = {}
  self.LightBodies = {}

  local grid = Levels
  local gridHeight = #grid
  local gridWidth = #grid[1]
  Map:initialize(grid, gridWidth, gridHeight)
  Player:initialize(self, vector(2*tileSize, 2*tileSize))

  self.Cells = {}
  self.state = 'game_start'

  -- This will be a general purpose table for *referencing* entities such as items, player,
  -- enemies, walls. Each entity requires a position vector.
  self.Entities = {Player}
  self.Projectiles = {}
  self.Links = createLinks(Levels)
  self:createColliders(grid, gridWidth, gridHeight)
  self:linkTerminalsAndDoors()
  -- post_shader = PostShader()
  -- post_shader:toggleEffect("blur", 2.0, 2.0)
  -- render_buffer = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())

  self.endScreenTimer = 2.0
  self.endFadeTimer = 2.0
  self.saveTextTimer = 0.0

  self.saveText = love.graphics.newText(controlsFont, "SAVED\npress   ESC   for   menu")
  self.displaySaveText = false

  self:save()
end

function Game:createColliders(grid, gridWidth, gridHeight)
  --Checkpoint:new(vector(2 * tileSize, 7 * tileSize))
  Map:loopGrid(function(x, y, val)
    local px, py = x * tileSize, y * tileSize
    if val == 1 then
      self.Cells[#self.Cells+1] = Cell:new(vector(px, py))
      self.LightBodies[#self.LightBodies+1] = lightWorld:newRectangle(px+tileSize/2, py+tileSize/2, tileSize, tileSize)
    end
    if val == 3 then
      self.Entities[#self.Entities+1] = Door:new(vector(px, py))
    end
    if val == 4 then
      self.Entities[#self.Entities+1] = Terminal:new(vector(px, py))
    end
    if val == 5 then
      self.Entities[#self.Entities+1] = Gap:new(vector(px, py))
    end
    if val == 6 then
      self.Entities[#self.Entities+1] = Checkpoint:new(self, vector(px, py))
    end
  end)
  -- hardcoded checkpoint
  self.Entities[#self.Entities+1] = Checkpoint:new(self, vector(21 * tileSize, 16 * tileSize))
  -- hardcoded end trigger
  local endX = #Levels > 20 and 14 or 11
  local endY = #Levels > 20 and 32 or 15
  self.Entities[#self.Entities+1] = Trigger:new(vector(endX * tileSize, endY * tileSize), function()
    self.state = 'game_over'
  end)
  Map:loopGrid(function(x, y, val)
    local px, py = x * tileSize, y * tileSize
    -- In this order so Crystals are drawn over Doors and Terminals
    if val == 2 then
      local crystal = Crystal:new(vector(px+tileSize/3, py+tileSize/3), 5)
      self.Entities[#self.Entities+1] = crystal
      local greyscale = math.random(100, 245)
      local light = lightWorld:newLight(px, py, greyscale, greyscale, greyscale, lightRange)
      light.z = 9

      self.Lights[#self.Lights+1] = { light=light, crystal=crystal }
    end
  end)
end

function Game:save()
  self.crystalPositions = {}
  self.terminalStates = {}
  for i = 1, #self.Entities do
    local e = self.Entities[i]
    if e.name == 'Crystal' then
      local x, y = e.collider:getPosition()
      self.crystalPositions[#self.crystalPositions+1] = vector(x, y)
    end
    if e.name == 'Terminal' then
      self.terminalStates[#self.terminalStates+1] = e.hasCrystal
    end
    if e.name == 'Player' then
      local x, y = e.collider:getPosition()
      self.savedPlayerPosition = vector(x, y)
    end
  end
  self.saveTextTimer = 3.0
end

function Game:load()
  if self.crystalPositions == nil or self.terminalStates == nil or self.savedPlayerPosition == nil then
    return
  end
  local ci = 0
  local ti = 0
  for i = 1, #self.Entities do
    local e = self.Entities[i]
    if e.name == 'Crystal' then
      ci = ci + 1
      local pos = self.crystalPositions[ci]
      e.collider:setPosition(pos.x, pos.y)
    end
    if e.name == 'Terminal' then
      ti = ti + 1
      e.hasCrystal = self.terminalStates[ti]
    end
    if e.name == 'Player' then
      local pos = self.savedPlayerPosition
      e.item = nil
      e.collider:setPosition(pos.x, pos.y)
    end
  end
end

function Game:linkTerminalsAndDoors()
  local doors = self:getEntities('Door')
  local terminals = self:getEntities('Terminal')
  for i = 1, #doors do
    local door = doors[i]
    local terminalVectors = {}
    for i = 1, #self.Links do
      local link = self.Links[i]
      if door.position.x == link.door.x and door.position.y == link.door.y then
        terminalVectors = link.terminals
        break
      end
    end
    local terms = {}
    for i = 1, #terminalVectors do
      local term = self:findEntityByVector(terminals, terminalVectors[i])
      terms[#terms+1] = term
    end
    door.terminals = terms
  end
end

local thing = 0
function Game:update(dt)
  Game:checkState()
  if self.state == 'game_over' then
    self:finUpdate(dt)
  end
  world:update(dt)
  for i = 1, #self.Entities do
    local entity = self.Entities[i]
    if entity.name == 'Player' then
      entity:update(dt)
      entity:handleShoot(dt, self.Projectiles)
    elseif entity.name == 'Crystal' then
      local terminals = self:getEntities('Terminal')
      entity:update(dt, terminals)
    else
      entity:update(dt)
    end
  end
  for i = #self.Projectiles, 1, -1 do
    local proj = self.Projectiles[i]
    if proj.collider:isDestroyed() then
      table.remove(self.Projectiles, i)
    else
      proj:update(dt, self.Projectiles)
    end
  end

  local camX, camY = Player.position.x, Player.position.y
  cam:lookAt(camX, camY)
  cam:zoomTo(4, 4)

  self:updateLights()

  gameUtils.removePower(dt)

  local lx, ly = -Player.position.x * 4, -Player.position.y * 4
  lightWorld:setTranslation(-64 + lx + love.graphics.getWidth() / 2 + tileSize * 4 / 2,
    -64 + ly + love.graphics.getHeight() / 2 + tileSize * 4 / 2, 4)
  thing = thing + dt * 10
  -- lightWorld:setTranslation(-64 + lx, -64 + ly, 4)
  lightWorld:update(dt)

  if Pause.isPaused then
    Pause.update()
  end

  if self.saveTextTimer > 0 then
    self.saveTextTimer = self.saveTextTimer - dt
    self.displaySaveText = true
  else
    self.displaySaveText = false
  end
end

function Game:finUpdate(dt)
  if self.endFadeTimer > 0 then
    self.endFadeTimer = self.endFadeTimer - dt
    main_theme:setVolume(0.3 * (self.endFadeTimer / 2.0))
    return
  end

  -- fade out
  if self.endScreenTimer > 0 then
    self.endScreenTimer = self.endScreenTimer - dt
    return
  end
end

function Game:getEntities(name)
  local temp = {}
  for i = 1, #self.Entities do
    if self.Entities[i].name == name then
      -- print(self.Entities[i].collider.collision_class)
      table.insert(temp, self.Entities[i])
    end
  end
  return temp
end

function Game:findEntityByVector(entities, v)
  for i = 1, #entities do
    local entity = entities[i]
    if entity.position.x == v.x and entity.position.y == v.y then
      return entity
    end
  end
end

function Game:updateLights()
  for i = 1, #self.Lights do
    local light = self.Lights[i]
    light.light:setPosition(light.crystal.position.x+tileSize/2, light.crystal.position.y+tileSize/2)
  end
end

function Game:print()
  -- print(Player.laserActive)
end

function Game:checkState()
  if Player:hasFinishedMap() then
    self.state = 'level_change'
  end
end

function Game:drawEndScreen()
  if self.endFadeTimer > 0 then
    love.graphics.setColor(0, 0, 0, 255 * (1 - self.endFadeTimer / 2.0))
    love.graphics.rectangle('fill', 0, 0, 640, 640)
    return
  end
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(end_screen)
  love.graphics.setColor(0, 0, 0, 255 * self.endScreenTimer / 2.0)
  love.graphics.rectangle('fill', 0, 0, 640, 640)
  return
end

function Game:draw(bool)
  if not bool then return end

  cam:attach()

  lightWorld:draw(function()
    Map:drawLayer('floor')
    Map:drawLayer('stair')
    Map:drawLayer('wall')

    Player:drawParticles()
    self:drawEntities(true)
    self:drawProjectiles(true)

    Player:draw()
  end)

  cam:detach()
  if Pause.isPaused then
    Pause.draw()
  end

  if self.displaySaveText then
    love.graphics.draw(self.saveText, 40, 560)
  end

  if self.state == 'game_over' then
    self:drawEndScreen()
  end
end

function Game:drawEntities(bool)
  if not bool then return end
  for i = 1, #self.Entities do
    local entity = self.Entities[i]
    if entity.name ~= 'Player' then
      entity:draw()
      -- love.graphics.setColor(255,255,255)
      -- love.graphics.rectangle('line', entity.position.x, entity.position.y, tileSize, tileSize)
    end
  end
end

function Game:drawProjectiles(bool)
  for i = #self.Projectiles, 1, -1 do
    local proj = self.Projectiles[i]
    love.graphics.setColor(255,255,255)
    proj:draw()
  end
end

function Game:drawDebug(bool)
  if not bool and self.state ~= 'game_over' then return end
  cam:attach()
  Player:drawDebug(true)
  Map:drawDebug(false)
  cam:detach()
end

function Game:drawCells()
  for i = 1, #cells do
    local cell = cells[i]
    love.graphics.setColor(255,255,255)
    love.graphics.rectangle('line', cell.position.x, cell.position.y, cell.width, cell.height)
  end
end

function Game:keypressed(key)
  if key == 'escape' then
    Pause.isPaused = not Pause.isPaused
  end

  Player:keypressed(key)
end

function Game:keyreleased(key)
  Player:keyreleased(key)
end

function Game:mousepressed(x, y, button)
  -- replace with checking menu buttons
  Pause.mousepressed(x, y, button, self, main_theme)
end

return Game
