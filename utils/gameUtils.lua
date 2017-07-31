local gameUtils = {}

local START_COUNT = 10

function gameUtils.initialize()
  gameUtils.count = START_COUNT
  gameUtils.completedDoors = {}
  gameUtils.timer = 0
  gameUtils.max = 10
  gameUtils.maxCount = 20
end

function gameUtils.addPower(door)
  if #gameUtils.completedDoors > 0 then
    for i = 1, #gameUtils.completedDoors do
      if door.position == gameUtils.completedDoors[i].position then
        return
      end
    end
  end

  gameUtils.count = gameUtils.count + 1
  gameUtils.completedDoors[#gameUtils.completedDoors+1] = door

  if gameUtils.count > gameUtils.maxCount then
    gameUtils.count = gameUtils.maxCount
  end
end

function gameUtils.removePower(dt)
  if gameUtils.timer < gameUtils.max then
    gameUtils.timer = gameUtils.timer + dt
  else
    gameUtils.count = gameUtils.count - 1
    gameUtils.timer = 0
  end
end

return gameUtils