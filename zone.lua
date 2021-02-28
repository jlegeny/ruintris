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
    local tile = grid.matrix[xy[1]][xy[2]]
    if tile.kind == Tile.EMPTY or tile.exploding then
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
    grid.matrix[xy[1]][xy[2]] = Tile(grid.matrix[xy[1]][xy[2]]:explodes_to())
    zone_grid.matrix[xy[1]][xy[2]] = Tile(self.explodes_to)
  end
end

Zone.update = function(self, game)
  if self:is_filled(game.grid) then
    self:explode(game.grid, game.zones.grid)
  end
  if self.exploding then
    local any_xy = self.tiles[1]
    local any_tile = game.zones.grid.matrix[any_xy[1]][any_xy[2]]
    if any_tile.loops > 0 then
      for _, xy in ipairs(self.tiles) do
        game.grid.matrix[xy[1]][xy[2]] = Tile(Tile.EMPTY)
        game.zones.grid.matrix[xy[1]][xy[2]] = Tile(self.kind)
      end
      self.exploding = false
      game:post_explosion()
    end
  end
end

return Zone

