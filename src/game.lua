-- constants
tileSize = 32

-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'

-- TODO: implement animations
-- src
local Map = require 'src.map'
local Player = require 'src.player'

local Game = class('Game')

function Game:initialize()
  Map:initialize(20, 20)
  -- The spawn vector is based on the map grid position not the actual pixel positions...
  Player:initialize(vector(5, 5))

  -- This will be a general purpose table for *referencing* entities such as items, player,
  -- enemies, walls. Each entity requires a position vector.
  self.Entities = {
    Player,
  }
end

function Game:update(dt)
  -- Check for behavior first
  Map:applyEntityPositionsToGrid(self.Entities)
  Player:update(dt)
  -- Then update the turns
  -- TODO: add Queuing / turn based actions here 
end

function Game:printDebugString()
end

function Game:draw(bool)
  if not bool then return end

  Player:draw()
end

function Game:drawDebug(bool)
  if not bool then return end
  Player:drawDebug()
  Map:drawDebug()
end

function Game:keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end

  Player:handleKeys(key)
end

return Game
