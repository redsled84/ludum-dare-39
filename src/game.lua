-- constants
tileSize = 32
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
local ROT = require 'libs.rotLove.rot'
local vector = require 'libs.vector'

-- TODO: implement animations
-- src
local HUD = require 'src.hud'
local Map = require 'src.map'
local Player = require 'src.player'

local Game = class('Game')

function Game:initialize()
  local gridWidth = 30
  local gridHeight = 30
  local rogueMap = ROT.Map.Brogue(gridWidth, gridHeight):create()
  Map:initialize(rogueMap, gridWidth, gridHeight)
  -- The spawn vector is based on the map grid position not the actual pixel positions...
  local firstRoom = rogueMap:getRooms()[1]
  Player:initialize(vector(5, 5))

  -- This will be a general purpose table for *referencing* entities such as items, player,
  -- enemies, walls. Each entity requires a position vector.
  self.Entities = {
    Player,
  }
  self.state = 'game_start'
end

function Game:update(dt)
  -- Check for behavior first
  Game:checkState()

  if self.state ~= 'game_over' then
    Player:update(dt)
    local camX, camY = Player:getPixelPosition()
    cam:lookAt(camX, camY)
  end
  Map:bindEntitiesToGrid(self.Entities)

  -- Then update the turns
  -- TODO: add Queuing / turn based actions here 
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
    Player:draw()
    Map:drawLayer('wall')
    cam:detach()
    HUD:draw(Player)
  elseif self.state == 'game_over' then
    -- TODO: change game over screen with player animation dying and restarting game
    love.graphics.setColor(255,0,0)
    love.graphics.print('You Ran Out Of Power!',
      love.graphics.getWidth() / 2 - 16, love.graphics.getHeight() / 2)
  end
end

function Game:drawDebug(bool)
  if not bool or self.state ~= 'game_over' then return end
  Player:drawDebug(false)
  Map:drawDebug(false)
end

function Game:keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end

  Player:handleKeys(key, Map)
end

return Game
