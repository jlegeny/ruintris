local gu = require 'gameutil'

local Tile = require 'tile'

local Piece = {}
Piece.__index = Piece

setmetatable(Piece, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Piece.L_RIGHT = 'l-right'

Piece.GREEN = 'green'

Piece.new = function(shape, color)
  local self = {}
  setmetatable(self, Piece)

  self.shape = shape
  self.color = color
  self.x = 0
  self.y = 0

  self.grid = nil
  if self.shape == Piece.L_RIGHT then
    self.grid = make_l_right(self.color)
  else
    io.stderr:write('Unknown piece shape')
    love.event.quit(1)
  end

  return self
end

Piece.set_position = function(self, x, y)
  self.x = x
  self.y = y
end

Piece.allowed_at = function(self, grid, x, y)
  -- check for bounds
  local minx, maxx, miny, maxy = gu.matrix_bounds(self.grid.matrix)
  if x + minx < 0 then
    return false
  end

  if x + maxx > grid.width - 1 then
    return false
  end

  if y + maxy > grid.height - 1 then
    return false
  end

  for c, column in ipairs(self.grid.matrix) do
    if x + c >= 1 and x + c <= grid.width then
      for r, tile in ipairs(column) do
        if y + r >= 1 and y + r <= grid.height then
          if tile.kind ~= Tile.EMPTY then
            if grid.matrix[x + c][y + r].kind ~= Tile.EMPTY then
              return false
            end
          end
        end
      end
    end
  end
  
  -- check for solids
  return true
end

Piece.update = function(dt)
end

function make_l_right(color)
  local grid = gu.mk_grid(3, 3)

  local tile_kind
  if color == Piece.GREEN then
    tile_kind = Tile.GREEN_FALLING
  else
    io.stderr:write('Unknown piece color\n')
    love.event.quit(1)
  end

  grid.matrix[2][1] = Tile(tile_kind)
  grid.matrix[2][2] = Tile(tile_kind)
  grid.matrix[2][3] = Tile(tile_kind)
  grid.matrix[3][3] = Tile(tile_kind)

  return grid
end

return Piece
