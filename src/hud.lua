local gameUtils = require 'utils.gameUtils'

-- libs
local class = require 'libs.middleclass'
local HUD = class('HUD')

local fontSize = 24
local thisFont = love.graphics.newFont('fonts/ARCADECLASSIC.TTF', fontSize)
thisFont:setFilter('nearest', 'nearest')

function HUD:draw(Player)
  -- drawing power bars
  local count = gameUtils.count
  if count < 7 then
    count = 7
  end
  local hudWidth = 8
  local hudHeight = 40
  local x = love.graphics.getWidth() / 2 - (count / 2)*hudWidth
  local y = love.graphics.getHeight() - hudHeight - 5
  local paddingX = hudWidth + 2

  love.graphics.setColor(255,255,255)
  local str = love.graphics.newText(thisFont, 'POWER')
  love.graphics.draw(str, love.graphics.getWidth()/2-str:getWidth()/3, y - fontSize)

  local powerShadowHeight = 16
  for i = 1, gameUtils.count do
    love.graphics.setColor(255,255,255)
    love.graphics.rectangle('fill', x+paddingX*(i-1), y, hudWidth, hudHeight-powerShadowHeight)
    love.graphics.setColor(255,255,255)
    love.graphics.rectangle('fill', x+paddingX*(i-1), y+hudHeight-powerShadowHeight, hudWidth, powerShadowHeight)
  end

  -- love.graphics.print('Power: ' .. tostring(Player:getPower()), x + 20, y + 10)
end

return HUD