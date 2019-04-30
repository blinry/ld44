local Follower = class("Follower", DynamicEntity)

function Follower:initialize(pos, acceleration, lifePoints)
    DynamicEntity.initialize(self, pos, acceleration, lifePoints)

    self.color = {r=(0.7+math.random()*0.3), g=(0.7+math.random()*0.3), b=(0.7+math.random()*0.3)}
end

return Follower
