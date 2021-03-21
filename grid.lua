local util = require 'util'
local Tile = require 'tile'

local Grid = {}
Grid.__index = Grid

setmetatable(Grid, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Grid.new = function(width, height, matrix)
  local self = {}
  setmetatable(self, Grid)

  self.width = width
  self.height = height
  self.matrix = matrix

  self.place_to_marker = {}
  self.marker_to_place = {}

  return self
end

Grid.add_marker = function(self, r, c, m)
  if not self.place_to_marker[r] then
    self.place_to_marker[r] = {}
  end
  self.place_to_marker[r][c] = m
  self.marker_to_place[m] = {r, c}
end

Grid.passable = function(self, x, y)
  local tile_at = self.matrix[x + 1][y + 1]
  util.log('Tile at {}, {} is {}', x + 1, y + 1, tile_at.kind)
  return tile_at.kind == Tile.EMPTY or tile_at.kind == Tile.CONTROL_PANEL or tile_at.kind == Tile.DOOR_TOP or tile_at.kind == Tile.DOOR_BOTTOM
end

Grid.update = function(self, dt)
  for c, column in ipairs(self.matrix) do
    for r, tile in ipairs(column) do
      tile:update(dt)
    end
  end
end

return Grid

