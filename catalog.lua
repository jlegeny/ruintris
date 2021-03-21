local util = require 'util'

local Catalog = {}
Catalog.__index = Catalog

setmetatable(Catalog, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

Catalog.backgrounds = {
  'bg-default',
  'bg-menu',
}
Catalog.tiles = {
  'tile-stone',
  'tile-green-0',
  'tile-green-1',
  'tile-green-2',
  'tile-green-exp-0',
  'tile-green-exp-1',
  'tile-green-exp-2',
  'tile-green-exp-3',
  'tile-red-0',
  'tile-red-1',
  'tile-red-2',
  'tile-red-exp-0',
  'tile-red-exp-1',
  'tile-red-exp-2',
  'tile-red-exp-3',
  'tile-zone-pink-0',
  'tile-zone-pink-1',
  'tile-zone-pink-2',
  'tile-zone-pink-exp-0',
  'tile-zone-pink-exp-1',
  'tile-zone-pink-exp-2',
  'tile-zone-pink-exp-3',
  'tile-control-panel',
  'tile-conveyor-left-0',
  'tile-conveyor-mid-0',
  'tile-conveyor-right-0',
  'tile-conveyor-left-1',
  'tile-conveyor-mid-1',
  'tile-conveyor-right-1',
  'tile-conveyor-left-2',
  'tile-conveyor-mid-2',
  'tile-conveyor-right-2',
  'tile-door-top-0',
  'tile-door-top-1',
  'tile-door-top-2',
  'tile-door-bottom-0',
  'tile-door-bottom-1',
  'tile-door-bottom-2',
}
Catalog.sprites = {
  'protagonist-idle-r',
  'protagonist-step-r-0',
  'protagonist-step-r-1',
  'protagonist-step-r-2',
  'protagonist-step-r-3',
  'protagonist-hoist-r-0',
  'protagonist-hoist-r-1',
  'protagonist-hoist-r-2',
  'protagonist-hoist-r-3',
  'protagonist-idle-l',
  'protagonist-step-l-0',
  'protagonist-step-l-1',
  'protagonist-step-l-2',
  'protagonist-step-l-3',
  'protagonist-hoist-l-0',
  'protagonist-hoist-l-1',
  'protagonist-hoist-l-2',
  'protagonist-hoist-l-3',
  'protagonist-squished',
  'scroll',
  'scroll-1',
  'scroll-2',
  'scroll-3',
  'scroll-4',
  'scroll-5',
  'scroll-6',
  'scroll-7',
  'scroll-8',
  'scroll-9',
 }

Catalog.new = function(image_names)
  local self = {}
  setmetatable(self, Catalog)

  self.image_data = {}
  self.count = 0
  self.image_names = image_names

  for i, name in ipairs(image_names) do
    util.log('Loading asset {}', name)
    local texture = love.graphics.newImage('assets/${name}.png' % { name = name })
    self.image_data[name] = {
      index = i,
      texture = texture,
      height = texture:getHeight(),
      width = texture:getWidth(),
    }
    self.count = self.count + 1
  end

  return self
end

Catalog.get = function(self, name)
  if not self.image_data[name] then
    io.stderr:write('Unknown texture ', util.str(name), '\n')
    love.event.quit(1)
  end

  return self.image_data[name]
end

return Catalog

