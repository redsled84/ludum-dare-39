-- utils
local audioUtils = require 'utils.audioUtils'
local colliderUtils = require 'utils.colliderUtils'
local vectorUtils = require 'utils.vectorUtils'

-- constants
local powerDecrement = 0.1
local laserCost = 0.5
local zeroVector = vectorUtils.getZeroVector()
local SHOOT_COOLDOWN = 0.5
local KEYS = {
  w = false,
  s = false,
  d = false,
  a = false,
  space = false,
}
local MAX_PARTICLES = 28

-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'
local io = require 'io'

-- src
local Projectile = require 'src.projectile'
local Timer = require 'src.timer'
-- local Tween = require 'src.tween'
local DIR2VEC = {
  left  = vector(-1, 0),
  right = vector( 1, 0),
  up    = vector( 0,-1),
  down  = vector( 0, 1),
}

local Player = class('Player')

function Player:initialize(game, spawnVector)
  self.game = game
  self.name = 'Player'
  self.position = spawnVector
  -- self.tween = Tween:new()
  self.width = tileSize
  self.height = tileSize
  self.item = nil
  self.hasItem = false
  self.shootTimer = 0.0
  self.dir = 'left'
  self.sprites = {
    up = love.graphics.newImage('sprites/player_up.png'),
    down = love.graphics.newImage('sprites/player_down.png'),
    left = love.graphics.newImage('sprites/player_left.png'),
    right = love.graphics.newImage('sprites/player_right.png'),
    particle = love.graphics.newImage('sprites/particle.png')
  }
  self.sounds = {
    pickup = {
      source = love.audio.newSource('audio/crystal_pickup.wav', 'static'),
      once = false,
    },
    shoot = {
      source = love.audio.newSource('audio/shoot.wav', 'static'),
      once = false,
    }
  }
  self.finishedMap = false
  self.velocity = zeroVector
  self.speed = 60
  self.actionKey = false
  self.hasCrystal = false
  self.collider = world:newCircleCollider(self.position.x, self.position.y, tileSize / 2.8)
  self.collider:setCollisionClass(self.name)
  self.collider:setFixedRotation(true)
  self.collider:setObject(self)
  self.psystem = love.graphics.newParticleSystem(self.sprites.particle, MAX_PARTICLES)
  -- between 0.5 and 1.0 seconds
  self.psystem:setParticleLifetime(0.25, .65)
  self.psystem:setSizeVariation(1)
  self.psystem:setSpread(.75)
  self.psystem:setSpin(math.pi/6, math.pi)
  self.psystem:setSpinVariation(.8)
  self.psystem:setColors(205, 200, 200, 240, 65, 55, 55, 0)
  self.psystem:setLinearDamping(-.8, -.1)

   self.endScreenTimer = 2.0
end

function Player:hasFinishedMap()
  return self.finishedMap
end

function Player:update(dt)
  self:movementWithKeys(dt)
  self.position = colliderUtils.getPosition(self.collider)
  --self:updateCollider(dt)
  if self.item ~= nil then
    self:updateItem(dt)
  end
  self:updateParticles()
  self.psystem:update(dt)

  if self.position.y > 32 * tileSize then
    -- fade to end screen
    self.endScreenTimer = self.endScreenTimer - dt
    main_theme:setVolume(0.3 * (self.endScreenTimer / 2.0))
    if self.endScreenTimer <= 0 then
      self.game.state = 'game_over'
    end
  end

  if self.collider:enter('Checkpoint') then
    self.game:save()
  end
end

function Player:handleShoot(dt, Projectiles)
  if self.shootTimer > 0.0 then
    self.shootTimer = self.shootTimer - dt
    return
  end
  -- fire projectile
  if KEYS['space'] and Projectiles and self.item ~= nil then
    Projectiles[#Projectiles+1] = Projectile:new(
      vector(
        self.position.x + tileSize/2.8,
        self.position.y + tileSize/2
      ),
      DIR2VEC[self.dir],
      {}
    )
    self.shootTimer = SHOOT_COOLDOWN
    audioUtils.play(self.sounds.shoot.source, not KEYS['space'])
  end
end

function Player:updateItem(dt)
  local x, y = self.collider:getPosition()
  self.item.collider:setPosition(x, y - tileSize / 3)
end

function Player:updateCollider(dt)
  local colliders
  if self.actionKey then
    local x, y = self.collider:getPosition()
    colliders = world:queryCircleArea(x, y, tileSize, {'Crystal', 'Terminal'})
  end
  if colliders then
    local crystal = nil
    for i = 1, #colliders do
      if colliders[i].collision_class == 'Crystal' then
        crystal = colliders[i]
        break
      end
      if colliders[i].collision_class == 'Terminal' then
        terminal = colliders[i]
        break
      end
    end
    if terminal and self.hasItem then
      self.item.collider:setPosition(terminal:getPosition())
      self.item.pickedUp = false
      self.item.placed = true
    end

    if crystal then
      local cx, cy = crystal:getPosition()
      local px, py = self.collider:getPosition()
      py = py - tileSize * 3/4
      crystal:setPosition(px, py)

      local vx = px - cx
      local vy = py - cy
      --crystal:setLinearVelocity(vx * 10, vy * 10)
      local obj = crystal:getObject()
      obj.pickedUp = true
      obj.placed = false
      audioUtils.play(self.sounds.pickup.source, self.sounds.pickup.once)
    else
      self.actionKey = false
    end
  end
  self.sounds.pickup.once = self.actionKey
end

function Player:movementWithKeys()
  self.velocity = zeroVector
  if KEYS['d'] then
    self.velocity.x = self.speed
    self.dir = 'right'
  elseif KEYS['a'] then
    self.velocity.x = -self.speed
    self.dir = 'left'
  elseif not KEYS['a'] and not KEYS['d'] then
    self.velocity.x = 0
  end
  if KEYS['s'] then
    self.velocity.y = self.speed
    self.dir = 'down'
  elseif KEYS['w'] then
    self.velocity.y = -self.speed
    self.dir = 'up'
  elseif not KEYS['w'] and not KEYS['s'] then
    self.velocity.y = 0
  end
  self.collider:setLinearVelocity(self.velocity.x, self.velocity.y)
end

function Player:updateParticles()
  if love.keyboard.isDown('d') then
    self.psystem:setSpeed(-self.speed)
    self.psystem:setDirection(2*math.pi)
    self.psystem:emit(2)
  elseif love.keyboard.isDown('a') then
    self.psystem:setSpeed(self.speed)
    self.psystem:setDirection(0)
    self.psystem:emit(2)
  elseif love.keyboard.isDown('s') then
    self.psystem:setSpeed(-self.speed)
    self.psystem:setDirection(math.pi/2)
    self.psystem:emit(2)
  elseif love.keyboard.isDown('w') then
    self.psystem:setSpeed(self.speed)
    self.psystem:setDirection(4.5*math.pi)
    self.psystem:emit(2)
  end
end

function Player:resetParticles(once)
  if self.psystem:isActive() then
    self.psystem:reset()
  end
end

function Player:checkItems(Items)
  for i = 1, #Items do
    local item = Items[i]
    if item.position == self.position and not self.hasItem and not item.pickedUp then
      item.pickedUp = true
      self.hasItem = true
      self.item = item
    end
  end
end

function Player:draw()
  self:drawSprites()
  love.graphics.setColor(0, 0, 0, 255 * (1 - self.endScreenTimer / 2.0))
  love.graphics.rectangle('fill', 0, 0, 640, 640)
end

function Player:drawParticles()
  love.graphics.setColor(255,255,255)
  local scale = .158
  if self.dir == 'right' then
    love.graphics.draw(self.psystem, self.position.x + 5, self.position.y + tileSize - 3, 0, scale, scale)
    love.graphics.draw(self.psystem, self.position.x + 5, self.position.y + tileSize - 6, 0, scale, scale)
  elseif self.dir == 'left' then
    love.graphics.draw(self.psystem, self.position.x + tileSize-5, self.position.y + tileSize - 3, 0, scale, scale)
    love.graphics.draw(self.psystem, self.position.x + tileSize-5, self.position.y + tileSize - 6, 0, scale, scale)
  elseif self.dir == 'up' then
    love.graphics.draw(self.psystem, self.position.x + 6, self.position.y + tileSize - 2, 0, scale, scale)
    love.graphics.draw(self.psystem, self.position.x + 11, self.position.y + tileSize - 2, 0, scale, scale)
  elseif self.dir == 'down' then
    love.graphics.draw(self.psystem, self.position.x + 6, self.position.y + 3, 0, scale, scale)
    love.graphics.draw(self.psystem, self.position.x + 11, self.position.y + 3, 0, scale, scale)
  end
end

function Player:drawSprites()
  local x, y = self.position.x, self.position.y
  love.graphics.setColor(255,255,255)
  -- draw held item
  if self.hasItem then
    love.graphics.draw(self.sprites['crystal'], x, y - 4)
  end
  -- draw player sprite
  love.graphics.draw(self.sprites[self.dir], x, y)
  -- draw held item
  if self.item ~= nil then
    self.item:draw()
  end
end

function Player:drawDebug(bool)
  if not bool then return end
  local x, y = self.position.x, self.position.y
  love.graphics.setColor(255,255,255)
  love.graphics.rectangle('line', x, y, tileSize, tileSize)
end

function Player:keypressed(key)
  if key and self.psystem:getCount() > MAX_PARTICLES then
    self:resetParticles()
  end
  for k, v in pairs(KEYS) do
    if k == key and not v then
      KEYS[k] = true
    end
  end
  if key == 'e' then
    self:action()
  end
end

function Player:action()
  local x, y = self.collider:getPosition()
  if self.item ~= nil then
    local colliders = world:queryCircleArea(x, y, tileSize * 2/3, {'Terminal'})
    if #colliders == 0 then
      -- drop the crystal
      self.item.pickedUp = false
      self.item = nil
    else
      -- put the crystal in the terminal
      local terminal_collider = colliders[1]
      local terminal = terminal_collider:getObject()
      if terminal.hasCrystal then return end
      self.item.collider:setPosition(terminal_collider:getPosition())
      self.item.pickedUp = false
      terminal:putCrystal()
      self.item = nil
    end

  else
    local colliders = world:queryCircleArea(x, y, tileSize * 2/3, {'Crystal'})
    if #colliders == 0 then return end
    local crystal_collider = colliders[1]
    self.item = crystal_collider:getObject()
    self.item.pickedUp = true
    audioUtils.play(self.sounds.pickup.source, not self.item.pickedUp)
  end
end

function Player:keyreleased(key)
  for k, v in pairs(KEYS) do
    if k == key and v then
      KEYS[k] = false
    end
  end
end

return Player
