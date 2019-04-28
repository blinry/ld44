-- NOTE: class, Entity are not required since they are globablly defined in main.lua
local Key = class("Key", Entity)

function Key:initialize(pos)
    Entity.initialize(self, pos, 1)
end

function Key:radius()
  return 50
end

return Key
