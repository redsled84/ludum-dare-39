-- libs
local class = require 'libs.middleclass'
local vector = require 'libs.vector'

-- src
--

local Tween = class('Tween')

function Tween:initialize()
    self.progress = 1.0
end

function Tween:start(startPos, endPos, duration)
    self.startPos = startPos
    self.endPos = endPos
    self.duration = duration
    self.progress = 0.0
end

function Tween:update(dt)
    if self.progress < 1.0 then
        self.progress = self.progress + dt / self.duration
    end
    -- We might overshoot 1.0, so we add a ceiling for it.
    if self.progress > 1.0 then
        self.progress = 1.0
    end
end

function Tween:position()
    return self.startPos * (1.0 - self.progress) + self.endPos * self.progress
end

function Tween:inProgress()
    return 0.0 <= self.progress and self.progress < 1.0
end

return Tween
