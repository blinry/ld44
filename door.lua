-- NOTE: class, Entity are not required since they are globablly defined in main.lua
local Door = class("Door", Wall)

function Door:initialize(pos, width, height)
    -- position is the left top position of the square.
    Wall.initialize(self, pos, width, height)

    self.color = {r=0.6, g=0.35, b=0.1, a=1}
    self.locked = true
end

function Door:unlock()
    self.body:setActive(false)
    self.color.a = 0.3
end

function Door:lock()
    self.body:setActive(true)
    self.color.a = 1
end

function Door:update()
    if self.locked then
        self:lock()
    else
        self:unlock()
    end
end

return Door
