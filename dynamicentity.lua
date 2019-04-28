-- NOTE: class, Entity are not required since they are globablly defined in main.lua
local DynamicEntity = class("DynamicEntity", Entity)

function DynamicEntity:initialize(pos, speed, lifePoints)
    Entity.initialize(self, pos, speed, lifePoints)

    self.body = love.physics.newBody(world, pos.x, pos.y, "dynamic")
    self.shape = love.physics.newCircleShape(50)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setFriction(0)
    --self.body:setInertia(100000)
    self.body:setMass(50)
end

return DynamicEntity
