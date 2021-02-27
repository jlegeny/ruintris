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

Piece.update = function(dt)
end

function make_l_right(color)
  local grid = gu.mk_grid(3, 3)

  local tile_kind
  if color == Piece.GREEN then
    tile_kind = Tile.GREEN
  else
    io.stderr:write('Unknown piece color')
    love.event.quit(1)
  end

  grid.matrix[2][1] = Tile(tile_kind)
  grid.matrix[2][2] = Tile(tile_kind)
  grid.matrix[2][3] = Tile(tile_kind)
  grid.matrix[3][3] = Tile(tile_kind)

  return grid
end

return Piece
