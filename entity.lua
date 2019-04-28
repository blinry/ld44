local class = require "lib.middleclass"

local Entity = class('Entity')

function Entity:initialize(pos, lifePoints)
  self.pos = pos
  self.lifePoints = lifePoints
  self.attractiveness = attractiveness
end

function Entity:attractiveness()
    return self.lifePoints
end

function Entity:position()
    return self.pos
end

function Entity:update()
    -- nop
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
