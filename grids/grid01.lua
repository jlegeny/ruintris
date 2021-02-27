local gu = require 'gameutil'
local Tile = require 'tile'

local function make()
  local grid = gu.mk_grid(15, 24)

  for i = 1, 15 do
    grid.matrix[i][24] = Tile(Tile.STONE)
  end
  grid.matrix[5][23] = Tile(Tile.STONE)
      
  return grid
end

return make()
