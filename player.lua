
local Player = class("Player", DynamicEntity)

function Player:initialize(pos, acceleration, lifePoints)
    DynamicEntity.initialize(self, pos, acceleration, lifePoints)
    self.beingDamaged = 0
end

return Player
