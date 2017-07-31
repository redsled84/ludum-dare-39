local colliderUtils = require 'utils.colliderUtils'

local class = require 'libs.middleclass'

local Terminal = class('Terminal')

local TEMP_ON_DURATION = 0.5

function Terminal:initialize(position)
  self.name = 'Terminal'
  self.onTimer = 0.0
  self.isTempOn = false
  self.position = position
  local shave = 5
  self.collider = world:newRectangleCollider(position.x + shave / 2, position.y + shave / 2,
    tileSize - shave, tileSize - shave)
  self.collider:setType('static')
  self.collider:setCollisionClass('Terminal')
  self.sprite = love.graphics.newImage('sprites/terminal.png')
  self.hasCrystal = false
  self.collider:setObject(self)
  print(self.position)
end

function Terminal:turnOnTemp()
  self.onTimer = TEMP_ON_DURATION
end

function Terminal:isOn()
  return self.hasCrystal or self.isTempOn
end

function Terminal:update(dt)
  if self.onTimer > 0.0 then
    self.isTempOn = true
    self.onTimer = self.onTimer - dt
  else
    self.isTempOn = false
  end
  -- self.position = colliderUtils.getPosition(self.collider)
  if self.collider:enter('Crystal') then
    self.hasCrystal = true
  end
  if self.collider:exit('Crystal') then
    self.hasCrystal = false
  end
end

function Terminal:draw()
  love.graphics.draw(self.sprite, self.position.x, self.position.y)
end

return Terminal
