local audioUtils = require 'utils.audioUtils'
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
  self.sounds = {
    placed = {
      source = love.audio.newSource('audio/crystal_placed.wav', 'static'),
      once = false
    }
  }
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
    local collision_data = self.collider:getEnterCollisionData('Crystal')
    local crystal = collision_data.collider:getObject()
    if not crystal.pickedUp then
      self:putCrystal()
    end
  end
  if self.collider:exit('Crystal') then
    self.hasCrystal = false
  end
  self.sounds.placed.once = self.hasCrystal
end

function Terminal:putCrystal()
  audioUtils.play(self.sounds.placed.source, self.sounds.placed.once)
  self.hasCrystal = true
end

function Terminal:draw()
  if not self.hasCrystal then
    love.graphics.setColor(255,100,100)
  else
    love.graphics.setColor(100,255,185)
  end
  if self.isTempOn then
    love.graphics.setColor(60,145,255)
  end
  love.graphics.draw(self.sprite, self.position.x, self.position.y)
end

return Terminal
