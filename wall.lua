-- NOTE: class, Entity are not required since they are globablly defined in main.lua
local Wall = class("Wall", Entity)

function Wall:initialize(pos, width, height)
    -- position is the left top position of the square.
    Entity.initialize(self, pos)
    self.width = width
    self.height = height

    self.color = {r=0.5, g=0.5, b=0.5}

    self.body = love.physics.newBody(world, pos.x, pos.y, "static")
    self.shape = love.physics.newRectangleShape(width/2, height/2, width, height)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setFriction(0)
    self.fixture:setUserData(self)
end

return Wall
