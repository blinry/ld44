
local Player = class("Player", DynamicEntity)

function Player:initialize(pos, acceleration, lifePoints)
    DynamicEntity.initialize(self, pos, acceleration, lifePoints)
    self.beingDamaged = 0
end

function Player:update()
    DynamicEntity.update(self)
    if self.lifePoints <= 0 then
        die()
    end
end

return Player
