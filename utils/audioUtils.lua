local audioUtils = {}

function audioUtils.play(source, once)
  if source:isPlaying() and not once then
    source:stop()
    source:play()
  elseif not once then
    source:play()
  end
end

return audioUtils