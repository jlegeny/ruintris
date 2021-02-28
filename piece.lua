local gu = require 'gameutil'
local matrix = require 'matrix'

local Tile = require 'tile'

local Piece = {}
Piece.__index = Piece

setmetatable(Piece, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Piece.L_RIGHT = 'l-right'
Piece.L_LEFT = 'l-left'
Piece.S_RIGHT = 's-right'
Piece.S_LEFT = 's-left'

Piece.GREEN = 'green'

Piece.CW = 'cw'
Piece.CCW = 'ccw'

Piece.new = function(shape, color)
  local self = {}
  setmetatable(self, Piece)

  self.shape = shape
  self.color = color
  self.x = 0
  self.y = 0
  self.ox = 0
  self.oy = 0

  self.grid = make(self.shape, self.color)

  return self
end

Piece.new_empty = function(width, height)
  local self = {}
  setmetatable(self, Piece)

  self.x = 0
  self.y = 0
  self.ox = 0
  self.oy = 0

  self.grid = gu.mk_grid(width, height)
  
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

  -- check for solids
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
  
  return true
end

Piece.embed = function(self, matrix)
  for c, column in ipairs(self.grid.matrix) do
    for r, tile in ipairs(column) do
      if not (tile.kind == Tile.EMPTY) then
        matrix[self.x + c][self.y + r] = Tile(tile:embeds_to())
      end
    end
  end
end

Piece.rotate = function(self, direction)
  if direction == Piece.CW then
    matrix.transpose(self.grid.matrix)
    matrix.reverse_rows(self.grid.matrix)
  elseif direction == Piece.CCW then
    matrix.transpose(self.grid.matrix)
    matrix.reverse_columns(self.grid.matrix)
  end
end

Piece.update = function(dt)
end

function make(shape, color)
  local grid = gu.mk_grid(3, 3)

  local tile_kind
  if color == Piece.GREEN then
    tile_kind = Tile.GREEN_FALLING
  else
    io.stderr:write('Unknown piece color\n')
    love.event.quit(1)
  end

  if shape == Piece.L_RIGHT then
    grid.matrix[2][1] = Tile(tile_kind)
    grid.matrix[2][2] = Tile(tile_kind)
    grid.matrix[2][3] = Tile(tile_kind)
    grid.matrix[3][3] = Tile(tile_kind)
  elseif shape == Piece.L_LEFT then
    grid.matrix[2][1] = Tile(tile_kind)
    grid.matrix[2][2] = Tile(tile_kind)
    grid.matrix[2][3] = Tile(tile_kind)
    grid.matrix[1][3] = Tile(tile_kind)
  elseif shape == Piece.S_RIGHT then
    grid.matrix[1][1] = Tile(tile_kind)
    grid.matrix[1][2] = Tile(tile_kind)
    grid.matrix[2][2] = Tile(tile_kind)
    grid.matrix[2][3] = Tile(tile_kind)
  elseif shape == Piece.S_LEFT then
    grid.matrix[2][1] = Tile(tile_kind)
    grid.matrix[1][2] = Tile(tile_kind)
    grid.matrix[2][2] = Tile(tile_kind)
    grid.matrix[1][3] = Tile(tile_kind)
  else
    io.stderr:write('Unknown piece shape\n')
    love.event.quit(1)
  end


  return grid
end

return Piece
