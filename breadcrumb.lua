-- NOTE: class, Entity are not required since they are globablly defined in main.lua
local BreadCrumb = class("BreadCrumb", Entity)

function BreadCrumb:initialize(pos, lifePoints, timePlaced)
    Entity.initialize(self, pos, lifePoints)
    self.color = {r=math.random(), g=math.random(), b=math.random()}
    self.timePlaced = timePlaced
end

function BreadCrumb:radius()
  return math.sqrt(self.lifePoints)*20
end

return BreadCrumb
