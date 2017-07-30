local vector = require 'libs.vector'
local colliderUtils = {}

function colliderUtils.getPosition(collider)
  local x, y = collider:getPosition()
  return vector(x - tileSize / 2, y - tileSize / 2)
end

return colliderUtils