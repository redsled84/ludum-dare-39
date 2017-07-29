-- src
local Game = require 'src.game'

-- General stuff:
--   * love.load executed once at the first (or close too) frame(s)
--   * love.update executes every frame
--   * love.draw executes every frame
--   * love.keypressed exectures when any key has been pressed

-- Also, the `#` operator means length of (much like `len` in Python)

-- You'll notice order functions are defined in source files are generally following this
-- same order here.

function love.load()
  Game:initialize()
end

function love.update(dt)
  Game:update(dt)
end

function love.draw()
  Game:draw(true)
  Game:drawDebug(true)
end

function love.keypressed(key)
  Game:keypressed(key)
end
