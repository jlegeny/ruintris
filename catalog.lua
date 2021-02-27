local util = require 'util'

local Catalog = {}
Catalog.__index = Catalog

setmetatable(Catalog, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

Catalog.backgrounds = { 'dusk', }
Catalog.tiles = { 'tile-stone', 'tile-green-0', 'tile-green-1', 'tile-green-2'}
Catalog.sprites = {
  'protagonist-idle-r',
  'protagonist-step-r-0',
  'protagonist-step-r-1',
  'protagonist-step-r-2',
  'protagonist-step-r-3',
  'protagonist-idle-l',
  'protagonist-step-l-0',
  'protagonist-step-l-1',
  'protagonist-step-l-2',
  'protagonist-step-l-3',
}

Catalog.new = function(image_names)
  local self = {}
  setmetatable(self, Catalog)

  self.image_data = {}
  self.count = 0
  self.image_names = image_names

  for i, name in ipairs(image_names) do
    print('Loading asset ', name)
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

