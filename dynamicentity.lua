-- NOTE: class, Entity are not required since they are globablly defined in main.lua
local DynamicEntity = class("DynamicEntity", Entity)

function DynamicEntity:initialize(pos, speed, lifePoints)

    Entity.initialize(self, pos, lifePoints)

    self.speed = speed
    self.flip = 1
    self.shape_radius = 50 -- refactor this later
    self.body = love.physics.newBody(world, pos.x, pos.y, "dynamic")
    self.shape = love.physics.newCircleShape(self.shape_radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setFriction(0)
    self.fixture:setUserData(self)
    --self.body:setInertia(100000)
    self.body:setMass(20)
end

function DynamicEntity:update()
    vx = self.body:getLinearVelocity()
    if vx >= 20 then
        self.flip = 1
    end
    if vx <= -20 then
        self.flip = -1
    end
end

function DynamicEntity:position()
    return vector(self.body:getPosition())
end

function DynamicEntity:radius()
    return math.sqrt(self.lifePoints)
end

return DynamicEntity
