local util = require 'util'

local Menu = {}
Menu.__index = Menu

setmetatable(Menu, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Menu.new = function(levels)
  local self = {}
  setmetatable(self, Menu)

  self.levels = levels

  return self
end

Menu.update = function(self, dt)
end

Menu.keypressed = function(self, key, unicode)
end

return Menu


