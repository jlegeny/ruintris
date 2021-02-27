local util = require 'util'
local gu = require 'gameutil'

local Tile = require 'tile'
local Piece = require 'piece'
local Game = require 'game'

local function entered(x, y, fromx, fromy, game)
  util.log('Entered {}, {} from {}, {}', x, y, fromx, fromy)
  local r, c = x + 1, y + 1
  local fr, fc = fromx + 1, fromy + 1
  if r == 10 and c == 23 then
    game.text = 'Press [space] to interact with the wheel. Press [space] again to go back to exploring.'
  end
end

local function trigger(x, y, game)
  util.log('Triggered tile at {}, {}', x, y)
  local tile_at = game.grid.matrix[x + 1][y + 1]
  -- CONTROL_PANELS
  if tile_at.kind == Tile.CONTROL_PANEL then
    local piece = Piece(Piece.L_RIGHT, Piece.GREEN)
    game:add_falling_piece(piece)
    game.state = Game.CTRL_FALLING_PIECE
  end
  
end

local function covered(x, y, game)
end

local function uncovered(x, y, game)
end

local function make()
  local grid = gu.mk_grid(15, 24)

  for c = 1, 15 do
    grid.matrix[c][24] = Tile(Tile.STONE)
  end
  grid.matrix[3][23] = Tile(Tile.STONE)
  grid.matrix[2][22] = Tile(Tile.STONE)
  grid.matrix[2][23] = Tile(Tile.STONE)

  grid.matrix[14][22] = Tile(Tile.STONE)
  grid.matrix[14][23] = Tile(Tile.STONE)
  grid.matrix[13][23] = Tile(Tile.STONE)

  grid.matrix[10][23] = Tile(Tile.CONTROL_PANEL)

  grid.script = {
    entered = entered,
    trigger = trigger,
    covered = covered,
    uncovered = uncovered,
  }
      
  return grid
end

return make()
