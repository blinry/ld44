-- NOTE: class, Entity are not required since they are globablly defined in main.lua
local BreadCrumb = class("BreadCrumb", Entity)

function BreadCrumb:initialize(pos, speed, lifePoints)
    Entity.initialize(self, pos, speed, lifePoints)
    self.color = {r=math.random(), g=math.random(), b=math.random()}
end

function BreadCrumb:radius()
  return math.sqrt(self.lifePoints)*20
end

return BreadCrumb
