-- libs
local class = require 'libs.middleclass'
local HUD = class('HUD')

function HUD:draw(Player)
  local hudWidth = love.graphics.getWidth() / 4
  local hudHeight = 40
  local x = 20
  local y = love.graphics.getHeight() - hudHeight - 20

  love.graphics.setColor(255,255,255,230)
  love.graphics.rectangle('fill', x, y, hudWidth, hudHeight)
  love.graphics.setColor(0,0,0)
  love.graphics.print('Power: ' .. tostring(Player:getPower()), x + 20, y + 10)
end

return HUD