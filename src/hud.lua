local gameUtils = require 'utils.gameUtils'

-- libs
local class = require 'libs.middleclass'
local HUD = class('HUD')

local fontSize = 24
love.graphics.setNewFont('fonts/ARCADECLASSIC.TTF', fontSize)

function HUD:draw(Player)
  -- drawing power bars
  local hudWidth = 8
  local hudHeight = 40
  local x = love.graphics.getWidth() / 2 - (gameUtils.count / 2)*hudWidth
  local y = love.graphics.getHeight() - hudHeight - 20
  local paddingX = hudWidth + 2

  -- outline
  love.graphics.setColor(20,20,20)
  local bufferPadding = 10
  local shadowHeight = 20
  local shadowY = y - bufferPadding+hudHeight+bufferPadding*2-shadowHeight
  local outlineWidth = gameUtils.count * paddingX + bufferPadding*2
  love.graphics.rectangle('fill', x - bufferPadding, y - bufferPadding*3,
    outlineWidth, hudHeight+bufferPadding*4)
  -- love.graphics.setColor(35,35,35)
  -- love.graphics.rectangle('fill', x - bufferPadding, shadowY, outlineWidth, shadowHeight)

  love.graphics.setColor(235,235,235)
  love.graphics.print('POWER', love.graphics.getWidth()/2-20, y - fontSize)

  local powerShadowHeight = 16
  for i = 1, gameUtils.count do
    love.graphics.setColor(245,65,65,255)
    love.graphics.rectangle('fill', x+paddingX*(i-1), y, hudWidth, hudHeight-powerShadowHeight)
    love.graphics.setColor(150, 30, 30)
    love.graphics.rectangle('fill', x+paddingX*(i-1), y+hudHeight-powerShadowHeight, hudWidth, powerShadowHeight)
  end

  -- love.graphics.print('Power: ' .. tostring(Player:getPower()), x + 20, y + 10)
end

return HUD