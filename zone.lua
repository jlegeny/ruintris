local util = require 'util'
local Tile = require 'tile'

local Zone = {}
Zone.__index = Zone

setmetatable(Zone, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Zone.new = function(kind, tiles)
  local self = {}
  setmetatable(self, Zone)

  self.kind = kind
  self.tiles = tiles
  print(tiles)
  self.exploding = false

  self.explodes_to = nil
  if kind == Tile.ZONE_PINK then
    self.explodes_to = Tile.ZONE_PINK_EXP
  end

  return self
end

Zone.is_filled = function(self, grid)
  for _, xy in ipairs(self.tiles) do
    if grid.matrix[xy[1]][xy[2]].kind == Tile.EMPTY then
      return false
    end
  end
  util.log('Zone is filled')
  return true
end

Zone.explode = function(self, grid, zone_grid)
  util.log('Zone is exploding')
  self.exploding = true
  for _, xy in ipairs(self.tiles) do
    grid.matrix[xy[1]][xy[2]] = Tile(Tile.EMPTY)
    zone_grid.matrix[xy[1]][xy[2]] = Tile(self.explodes_to)
  end
end

Zone.update = function(self, grid, zone_grid)
  if self:is_filled(grid) then
    self:explode(grid, zone_grid)
  end
  if self.exploding then
    local any_xy = self.tiles[1]
    local any_tile = zone_grid.matrix[any_xy[1]][any_xy[2]]
    if any_tile.loops > 0 then
      for _, xy in ipairs(self.tiles) do
        zone_grid.matrix[xy[1]][xy[2]] = Tile(self.kind)
      end
      self.exploding = false
    end
  end
end

return Zone

