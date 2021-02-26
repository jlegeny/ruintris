local Tile = require 'tile'

local function make()
  local w, h = 15, 24

  local grid = {}

  for r = 1, h do
    grid[r] = {}
    for c = 1, w do
      grid[r][c] = Tile(Tile.EMPTY)
    end
  end

  grid[10][10] = Tile(Tile.STONE)
      
  grid.width = w
  grid.height = h

  return grid
end

return make()
