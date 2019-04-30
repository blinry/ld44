
local Player = class("Player", DynamicEntity)

function Player:initialize(pos, acceleration, lifePoints)
    DynamicEntity.initialize(self, pos, acceleration, lifePoints)
    self.beingDamaged = 0
end

function Player:update()
    DynamicEntity.update(self)
    if self.lifePoints <= 0 then
        die("You were killed by a capitalist pig. Sure, they look cute, but don't underestimate them. They are extremely dangerous.")
    end
end

function Player:attractiveness()
    return self.lifePoints/8
end

return Player
