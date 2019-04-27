local class = require "lib.middleclass"

local Entity = class('Entity')

function Entity:initialize(pos, speed, scaleFactor)
  self.pos = pos
  self.speed = speed
  self.scaleFactor = scaleFactor
end

function Entity:resize(sizeFactor)
  self.scaleFactor = self.scaleFactor * sizeFactor
end

return Entity

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
