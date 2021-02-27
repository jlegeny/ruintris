local Grid = require 'grid'
local Tile = require 'tile'

local gu = {}

gu.mk_grid = function(w, h)
  local matrix = {}

  for r = 1, h do
    matrix[r] = {}
    for c = 1, w do
      matrix[r][c] = Tile(Tile.EMPTY)
    end
  end

  return Grid(w, h, matrix)
end

return gu
