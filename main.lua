-- constants
-- libs
--

-- src
local Game = require 'src.game'

-- General stuff:
--   * love.load executed once at the first (or close too) frame
--   * love.update executes every frame
--   * love.draw executes every frame
--   * love.keypressed exectures every key press

-- You'll notice order functions are defined in source files are generally following this exact
-- same order here.

function love.load()
  Game:initialize()
end

function love.update(dt)
  Game:update(dt)
  Game:printDebugString(true)
end

function love.draw()
  Game:draw(true)
  Game:drawDebug(true)
end

function love.keypressed(key)
  Game:keypressed(key)
end
