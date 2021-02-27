local gu = require 'gameutil'
local Tile = require 'tile'

local function make()
  local grid = gu.mk_grid(15, 24)

  grid.matrix[10][10] = Tile(Tile.STONE)
      
  return grid
end

return make()
