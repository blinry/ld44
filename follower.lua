local Follower = class("Follower", DynamicEntity)

function Follower:initialize(pos, acceleration, lifePoints)
    DynamicEntity.initialize(self, pos, acceleration, lifePoints)
end

return Follower
