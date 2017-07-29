-- libs
local vector = require 'libs.vector'

local vectorUtils = {}

function vectorUtils.getZeroVector()
  return vector(0, 0)
end

return vectorUtils
