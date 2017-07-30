-- constants
tileSize = 16
states = {
  game_start = 'game_start',
  game_over = 'game_over',
  ingame_menu = 'ingame_menu',
  splash_menu = 'splash_menu',
  level_change = 'level_change'
}

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
world:addCollisionClass('Player')

-- TODO: implement animations
-- src
local Cell = require 'src.cell'
local Crystal = require 'src.crystal'
local Door = require 'src.door'
local HUD = require 'src.hud'
local Map = require 'src.map'
local Player = require 'src.player'

local Game = class('Game')

function Game:initialize(firstTime)
  love.graphics.setDefaultFilter('nearest', 'nearest')
  -- lightWorld = LightWorld({
  --   ambient = {45, 45, 45},
  --   refractionStrength = 1.0,
  --   reflectionVisibility = 0.95,
  --   shadowBlur = 0.0
  -- })

  -- lightPlayer = lightWorld:newLight(0, 0, 200, 150, 100, 235)
  -- lightObjects = {}

  local grid = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 0, 0, 1, 1, 1, 0, 1},
    {1, 1, 0, 0, 0, 1, 1, 1, 0, 1},
    {1, 0, 0, 0, 0, 1, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 1, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 3, 1, 1, 0, 2, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  }
  local gridHeight = #grid
  local gridWidth = #grid[1]
  Map:initialize(grid, gridWidth, gridHeight)

  
  Player:initialize(vector(2*tileSize, 4*tileSize))
  
  self.Cells = {}
  self.Items = {}
  self.Doors = {}
  self.state = 'game_start'

  -- This will be a general purpose table for *referencing* entities such as items, player,
  -- enemies, walls. Each entity requires a position vector.
  self:createColliders(grid, gridWidth, gridHeight)

  self.Entities = {Player, unpack(self.Items), unpack(self.Doors)}

  -- post_shader = PostShader()
  -- post_shader:toggleEffect("blur", 2.0, 2.0)
  -- render_buffer = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
end

function Game:createColliders(grid, gridWidth, gridHeight)
  for y = 1, gridHeight do
    for x = 1, gridWidth do
      local val = grid[y][x]
      local px, py = x * tileSize, y * tileSize
      if val == 1 then
        self.Cells[#self.Cells+1] = Cell:new(vector(px, py))
      end
      if val == 2 then
        self.Items[#self.Items+1] = Crystal:new(vector(px, py), 5)
      end
      if val == 3 then
        self.Doors[#self.Doors+1] = Door:new(vector(px, py))
      end
    end
  end
end

function Game:update(dt)
  Game:checkState()
  if self.state ~= 'game_over' then
    world:update(dt)

    for i = 1, #self.Entities do
      local entity = self.Entities[i]
      entity:update(dt)
    end

    local camX, camY = Player.position.x, Player.position.y
    cam:lookAt(camX, camY)
    cam:zoomTo(4, 4)

    -- lightPlayer:setPosition(camX + tileSize / 2, camY + tileSize / 2)
    -- local lx, ly = -cam.x, -cam.y
    -- lightWorld:setTranslation(lx, ly, 4)
    -- lightWorld:update(dt)
  end
  if self.state == 'level_change' then
    self:initialize(false)
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

function Game:draw(bool)
  if not bool then return end

  if self.state == 'game_start' then
    cam:attach()
    -- lightWorld:draw(function()
      Map:drawLayer('floor')
      Map:drawLayer('stair')
      Map:drawLayer('wall')

      self:drawItems(true)
      self:drawDoors(true)

      Player:draw()
    -- end)
    
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
  self:drawDebug(false)
end

function Game:drawItems(bool)
  if not bool then return end
  for i = 1, #self.Items do
    local item = self.Items[i]
    item:draw()
  end
end

function Game:drawDoors(bool)
  if not bool then return end
  for i = 1, #self.Doors do
    local door = self.Doors[i]
    door:draw()
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
    love.event.quit('restart')
  end
  if key == 'q' then
    love.event.quit()
  end
  if key == 'p' then
    local colliders = world:queryCircleArea(100, 100, 100)
    for _, collider in ipairs(colliders) do
      collider:applyLinearImpulse(1000, 1000)
    end
  end

  Player:keypressed(key)
end

function Game:keyreleased(key)
  Player:keyreleased(key)
end

function Game:mousepressed(x, y, button)
  -- replace with checking menu buttons
end

return Game
