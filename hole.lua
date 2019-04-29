local class = require "lib.middleclass"

local Hole =  class("Hole", Entity)

function Hole:initialize(pos, width, height)
  -- position is the left top position of the square.
  speed = 0
  scaleFactor = 1
  Entity.initialize(self, pos, speed, scaleFactor)
  self.width = width
  self.height = height
  gotFollower = false
end

return Hole
