local Tile = {}
Tile.__index = Tile

setmetatable(Tile, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Tile.SIZE = 12

Tile.EMPTY = 'empty'
Tile.STONE = 'stone'

Tile.new = function(kind)
  local self = {}
  setmetatable(self, Tile)

  self.kind = kind

  return self
end

Tile.texture_name = function(self)
  if self.kind == Tile.EMPTY then
    return nil
  elseif self.kind == Tile.STONE then
    return 'tile-stone'
  end
  return nil
end

return Tile

