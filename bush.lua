-- NOTE: class, Entity are not required since they are globablly defined in main.lua
local Bush = class("Bush", Entity)

function Bush:initialize(pos, width, height)
    -- position is the left top position of the square.
    Entity.initialize(self, pos)
    self.hiding_entities = {}
    self.width = width
    self.height = height
    -- These parameters are use to set the bush graphics
    self.heightRadius = height/2
    self.widthRadius = width/5
    self.detectionRadius = math.max(height, width)

    self.color = {r=0.5, g=0.5, b=0.5}
end

return Bush
