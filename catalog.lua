local Catalog = {}
Catalog.__index = Catalog

setmetatable(Catalog, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

Catalog.backgrounds = { 'dusk', }
Catalog.tiles = { 'tile-stone', }

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
  return self.image_data[name]
end

return Catalog

