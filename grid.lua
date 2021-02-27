local util = require 'util'
local Tile = require 'tile'

local Grid = {}
Grid.__index = Grid

setmetatable(Grid, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Grid.new = function(width, height, matrix, script)
  local self = {}
  setmetatable(self, Grid)

  self.width = width
  self.height = height
  self.matrix = matrix

  self.script = script

  return self
end

Grid.passable = function(self, x, y)
  local tile_at = self.matrix[x + 1][y + 1]
  util.log('Tile at {}, {} is {}', x + 1, y + 1, tile_at.kind)
  return tile_at.kind == Tile.EMPTY or tile_at.kind == Tile.CONTROL_PANEL
end

Grid.update = function(self, dt)
  for c, column in ipairs(self.matrix) do
    for r, tile in ipairs(column) do
      tile:update(dt)
    end
  end
end

return Grid

