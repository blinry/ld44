local class = require "lib.middleclass"

local Trap =  class("Trap", Entity)

function Trap:initialize(pos, radius)
  -- position is the left top position of the square.
  speed = 0
  scaleFactor = 1
  Entity.initialize(self, pos, speed, scaleFactor)
  self.radius = radius
  gotFollower = false
end

return Trap

-- Fruit.static.sweetness_threshold = 5 -- class variable (also admits methods)

-- function Fruit:isSweet()
--   return self.sweetness > Fruit.sweetness_threshold
-- end
-- 
-- local Lemon = class('Lemon', Fruit) -- subclassing
-- 
-- function Lemon:initialize()
--   Fruit.initialize(self, 1) -- invoking the superclass' initializer
-- end
-- 
-- local lemon = Lemon:new()
-- 
-- print(lemon:isSweet()) -- false
