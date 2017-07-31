local gameUtils = require 'utils.gameUtils'

-- libs
local class = require 'libs.middleclass'
local HUD = class('HUD')

function HUD:draw(Player)
  -- drawing power bars
  local hudWidth = 8
  local hudHeight = 40
  local x = love.graphics.getWidth() / 2 - (gameUtils.count / 2)*hudWidth
  local y = love.graphics.getHeight() - hudHeight - 20
  local paddingX = hudWidth + 2

  -- outline
  love.graphics.setColor(65,65,65)
  local bufferPadding = 10
  local shadowHeight = 20
  local shadowY = y - bufferPadding+hudHeight+bufferPadding*2-shadowHeight
  local outlineWidth = gameUtils.count * paddingX + bufferPadding*2
  love.graphics.rectangle('fill', x - bufferPadding, y - bufferPadding,
    outlineWidth, hudHeight+bufferPadding*2)
  love.graphics.setColor(35,35,35)
  love.graphics.rectangle('fill', x - bufferPadding, shadowY, outlineWidth, shadowHeight)

  local powerShadowHeight = 16
  for i = 1, gameUtils.count do
    love.graphics.setColor(245,120,115,255)
    love.graphics.rectangle('fill', x+paddingX*(i-1), y, hudWidth, hudHeight-powerShadowHeight)
    -- love.graphics.setColor(150, 30, 30)
    -- love.graphics.rectangle('fill', x+paddingX*(i-1), y+hudHeight-powerShadowHeight, hudWidth, powerShadowHeight)
  end

  -- love.graphics.print('Power: ' .. tostring(Player:getPower()), x + 20, y + 10)
end

return HUD