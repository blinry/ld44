-- NOTE: class, Entity are not required since they are globablly defined in main.lua
local DynamicEntity = class("DynamicEntity", Entity)

function DynamicEntity:initialize(pos, acceleration, lifePoints)
    Entity.initialize(self, pos, lifePoints)

    self.mobility = true
    self.acceleration = acceleration
    self.flip = 1

    self.color = {r=1, g=1, b=1, a=1}

    self.body = love.physics.newBody(world, pos.x, pos.y, "dynamic")
    self.shape = love.physics.newCircleShape(self:radius())
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setFriction(0)
    self.fixture:setUserData(self)
    --self.body:setInertia(100000)
    self.body:setMass(20)
    self.currentlyHeld = nil
end

function DynamicEntity:attractiveness()
    return self.lifePoints/2
end

function DynamicEntity:update()
    -- flip graphics, if needed
    vx = self.body:getLinearVelocity()
    if vx >= 20 then
        self.flip = 1
    end
    if vx <= -20 then
        self.flip = -1
    end

    if math.abs(self:radius() - self.shape:getRadius()) > 5 then
        -- update the radius
        local pos = self:position()
        local velocityX, velocityY = self.body:getLinearVelocity()

        self.fixture:destroy()
        self.body:destroy()

        self.body = love.physics.newBody(world, pos.x, pos.y, "dynamic")
        self.shape = love.physics.newCircleShape(self:radius())
        self.fixture = love.physics.newFixture(self.body, self.shape)
        self.fixture:setFriction(0)
        self.fixture:setUserData(self)
        --self.body:setInertia(100000)
        self.body:setMass(20)

        self.body:setLinearVelocity(velocityX, velocityY)
    end
end

function DynamicEntity:position()
    return vector(self.body:getPosition())
end

function DynamicEntity:radius()
    return math.sqrt(self.lifePoints)*10
end

return DynamicEntity
