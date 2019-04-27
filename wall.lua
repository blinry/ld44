-- NOTE: class, Entity are not required since they are globablly defined in main.lua
local Wall = class("Wall", Entity)

function Wall:initialize(pos, width, height)
    -- position is the left top position of the square.
    speed = 0
    scaleFactor = 1
    Entity.initialize(self, pos, speed, scaleFactor)
    self.width = width
    self.height = height
  end

return Wall
