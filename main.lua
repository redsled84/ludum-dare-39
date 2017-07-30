math.randomseed(os.time())
-- generate 3 randoms b/c programmer superstition :-P
math.random()
math.random()
math.random()

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
  Game:print()
end

function love.draw()
  Game:drawDebug(false)
  Game:draw(true)
end

function love.keypressed(key)
  Game:keypressed(key)
end

function love.mousepressed(x, y, button)
  Game:mousepressed(x, y, button)
end
