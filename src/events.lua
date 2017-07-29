-- libs
local class = require 'libs.middleclass'
local ROT = require 'libs.rotLove.rot'

local Events = class('Events')

function Events:initialize()
  self.Queue = {}
end

function Events:add(action, params, duration)
  table.insert(self.Queue, {action=action, params=params, duration=duration})
end

function Events:current()
  return self.Queue[#self.Queue]
end

function Events:pop()
  self.Queue[#self.Queue] = nil
end

local timer = 0
function Events:stepEvents(dt)
  if #self.Queue == 0 then return end
  for i = 1, #self.Queue do
    local event = self.Queue[i]
    if event then
      love.timer.sleep(event.duration)
      event.action(unpack(event.params))
      Events:pop()
    end
  end
end

return Events