-- NOTE: class, Entity are not required since they are globablly defined in main.lua
local Button = class("Button", Entity)

function Button:initialize(pos, radius)
    -- position is the left top position of the square.
    Entity.initialize(self, pos)
    self.hiding_entities = {}
    self.radius = radius
    self.switched = false
    self.color = {r=0.5, g=0.5, b=0.5}
    self.callback = nil
end


return Button
