local colliderUtils = require 'utils.colliderUtils'

local class = require 'libs.middleclass'

local Door = class('Door')

function Door:initialize(position, open)
  self.name = 'Door'
  self.position = position
  self.collider = world:newRectangleCollider(self.position.x, self.position.y, tileSize, tileSize/2)
  self.collider:setType('static')
  self.collider:setCollisionClass('Door')
  self.collider:setObject(self)
  self.sprites = {
    open = love.graphics.newImage('sprites/door_open.png'),
    close = love.graphics.newImage('sprites/door_closed.png'),
  }
  self.open = open or false
  self.terminals = {}
  self.collider:setPreSolve(function(c1, c2, contact)
    if c1.collision_class == 'Door' and c2.collision_class == 'Player' then
      contact:setEnabled(not self.open)
    end
  end)
end

function Door:update(dt)
  self.position = colliderUtils.getPosition(self.collider)
  local terminals = self.terminals
  if terminals then
    local count = 0
    for i = 1, #terminals do
      local terminal = terminals[i]
      if terminal:isOn() then
        count = count + 1
      end
    end
    if count >= #terminals then
      self.open = true
    else
      self.open = false
    end
  end
end

function Door:draw()
  local x, y = self.position.x, self.position.y
  love.graphics.setColor(255,255,255)
  if self.open then
    love.graphics.draw(self.sprites.open, x, y)
  else
    love.graphics.draw(self.sprites.close, x, y)
  end
end

return Door
