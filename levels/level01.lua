local util = require 'util'
local gu = require 'gameutil'
local i18n = require 'i18n'
local builder = require 'builder'

local Tile = require 'tile'
local Piece = require 'piece'
local Game = require 'game'

local level_str = {
  '               ',
  '               ',
  '               ',
  '               ',
  '               ',
  '               ',
  '               ',
  '               ',
  '              1',
  '###############',
}

local marker_tiles = {
  ['1'] = ' ',
}

local function make_grid()
  local grid = builder.initial_grid(level_str, marker_tiles)
  return grid
end

local script = {}

script.entered = function(game, x, y, fromx, fromy, game)
  util.log('Entered {}, {} from {}, {}', x, y, fromx, fromy)
  local r, c = x + 1, y + 1
  local fr, fc = fromx + 1, fromy + 1
  if r == 10 and c == 23 then
    game.text = i18n.help_wheel
  elseif r == 15 and c == 13 then
    game.state = Game.WINNER
  elseif fr == 10 and fc == 23 then
    game.text = ''
  end
end

script.trigger = function(x, y, game)
  util.log('Triggered tile at {}, {}', x, y)
  local tile_at = game.grid.matrix[x + 1][y + 1]
  -- CONTROL_PANELS
  if tile_at.kind == Tile.CONTROL_PANEL then
    if game.state == Game.CTRL_PROTAGONIST then
      if game.falling_piece then
        game.state = Game.CTRL_FALLING_PIECE
        game.text = i18n.help_piece
      else
        game.state = Game.CTRL_CONVEYOR
        game.text = i18n.help_conveyor
        generate_pieces(game)
      end
    elseif game.state == Game.CTRL_CONVEYOR or game.state == Game.CTRL_FALLING_PIECE then
      game.state = Game.CTRL_PROTAGONIST
      game.text = i18n.help_wheel
      game.script.conveyor(Game.STOP, game)
    end
    --local piece = Piece(Piece.L_RIGHT, Piece.GREEN)
    --piece:set_position(6, 0) 
    --game:add_falling_piece(piece)
  end
end

script.covered = function(x, y, game)
end

script.uncovered = function(x, y, game)
end

script.conveyor = function(direction, game)
  util.log('Conveyor turning {}', direction)
  if direction == Game.LEFT then
    set_conveyor(game.grid.matrix, Game.LEFT)
  elseif direction == Game.RIGHT then
    set_conveyor(game.grid.matrix, Game.RIGHT)
  elseif direction == Game.STOP then
    set_conveyor(game.grid.matrix, Game.STOP)
  end
end

script.update = function(dt, game)
  function let_it_go(p)
    game.falling_piece = p
    game:remove_piece(p.id)
    game.falling_piece:make_controlled()
    game.state = Game.CTRL_FALLING_PIECE
    game.text = i18n.help_piece
  end

  function reset_conveyor()
    if not state.piece_left and not state.piece_right then
      script.conveyor(Game.STOP, game)
      generate_pieces(game)
    end
  end

  state.conveyor_t = state.conveyor_t + dt
  if state.conveyor_t < CONVEYOR_TICK then
    state.conveyor_t = state.conveyor_t - CONVEYOR_TICK
    if state.piece_left then
      local p = state.piece_left
      if state.conveyor == Game.RIGHT then
        p.ox = p.ox + CONVEYOR_SPEED
        if p.x < 5 then
          if p.ox > Tile.SIZE / 2 then
            p.x = p.x + 1
            p.ox = p.ox - Tile.SIZE
          end
        else
          if p.ox == 0 then
            let_it_go(p)
            state.piece_left = nil
          end
        end
      elseif state.conveyor == Game.LEFT then
        p.ox = p.ox - CONVEYOR_SPEED
        if p.x > -4 then
          if p.ox < -Tile.SIZE / 2 then
            p.x = p.x - 1
            p.ox = p.ox + Tile.SIZE
          end
        else
          game:remove_piece(p.id)
          state.piece_left = nil
        end
      end
      reset_conveyor()
    end
    if state.piece_right then
      local p = state.piece_right
      if state.conveyor == Game.LEFT then
        p.ox = p.ox - CONVEYOR_SPEED
        if p.x > 7 then
          if p.ox < -Tile.SIZE / 2 then
            p.x = p.x - 1
            p.ox = p.ox + Tile.SIZE
          end
        else
          if p.ox == 0 then
            let_it_go(p)
            state.piece_right = nil
          end
        end
      elseif state.conveyor == Game.RIGHT then
        p.ox = p.ox + CONVEYOR_SPEED
        if p.x < 16 then
          if p.ox > Tile.SIZE / 2 then
            p.x = p.x + 1
            p.ox = p.ox - Tile.SIZE
          end
        else
          game:remove_piece(p.id)
          state.piece_right = nil
        end
      end
      reset_conveyor()
    end
  end
end

function build()
  local state = {
    piece_right = nil,
    piece_left = nil,
    conveyor = Game.STOP,
    conveyor_t = 0,
  }

  return {
    state = util.deepcopy(state),
    grid = make_grid(),
    zones = make_zones(), 
    script = script
  }
end

return {
  build = build
}
