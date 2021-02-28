local util = require 'util'
local gu = require 'gameutil'
local i18n = require 'i18n'

local Tile = require 'tile'
local Piece = require 'piece'
local Game = require 'game'
local Zone = require 'zone'

local CONVEYOR_TICK = 0.16
local CONVEYOR_SPEED = 2

local state = {
  piece_right = nil,
  piece_left = nil,
  conveyor = Game.STOP,
  conveyor_t = 0,
}

local level_str = {
  '               ',
  '               ',
  'C===D     C===D',
  '               ',
  '               ',
  '               ',
  '               ',
  '               ',
  '               ',
  '               ',
  '               ',
  '               ',
  '               ',
  '         ## ###',
  '              #',
  '              #',
  '              #',
  'v             #',
  '##            #',
  '##            #',
  '##            #',
  '##           ##',
  '###  ### v  ###',
  '###############',
}

local function set_conveyor(matrix, direction)
  state.conveyor = direction
  local cl = Tile.CONVEYOR_LEFT
  local cm = Tile.CONVEYOR_MID
  local cr = Tile.CONVEYOR_RIGHT
  if direction == Game.RIGHT then
    cl = Tile.CONVEYOR_LEFT_CW
    cm = Tile.CONVEYOR_MID_CW
    cr = Tile.CONVEYOR_RIGHT_CW
  elseif direction == Game.LEFT then
    cl = Tile.CONVEYOR_LEFT_CCW
    cm = Tile.CONVEYOR_MID_CCW
    cr = Tile.CONVEYOR_RIGHT_CCW
  end
  matrix[1][3] = Tile(cl)
  matrix[2][3] = Tile(cm)
  matrix[3][3] = Tile(cm)
  matrix[4][3] = Tile(cm)
  matrix[5][3] = Tile(cr)

  matrix[11][3] = Tile(cl)
  matrix[12][3] = Tile(cm)
  matrix[13][3] = Tile(cm)
  matrix[14][3] = Tile(cm)
  matrix[15][3] = Tile(cr)
end

local function generate_pieces(game)
  if state.piece_left or state.piece_right then
    return
  end
  local left_shape = Piece.random_shape()
  local left_color = Piece.random_color()
  left = Piece(left_shape, left_color)
  left.embeddable = false
  local minx, maxx, miny, maxy = gu.matrix_bounds(left.grid.matrix)
  left:set_position(1, 2 - maxy - 1)

  local right_shape = Piece.random_shape()
  while right_shape == left_shape do
    right_shape = Piece.random_shape()
  end
  local right_color = Piece.random_color()
  while right_color == left_color do
    right_color = Piece.random_color()
  end
  right = Piece(right_shape, right_color)
  right.embeddable = false
  local minx, maxx, miny, maxy = gu.matrix_bounds(right.grid.matrix)
  right:set_position(11, 2 - maxy - 1)

  state.piece_left = left
  state.piece_right = right
  table.insert(game.pieces, state.piece_left)
  table.insert(game.pieces, state.piece_right)
end


local _char_to_tile = {
  [' '] = Tile.EMPTY,
  ['#'] = Tile.STONE,
  ['v'] = Tile.CONTROL_PANEL,
}

local function make_grid()
  local grid = gu.mk_grid(15, 24)

  for r, row in ipairs(level_str) do
    for c = 1, #row do
      local t = row:sub(c, c)
      grid.matrix[c][r] = Tile(_char_to_tile[t])
    end
  end

  set_conveyor(grid.matrix, Game.STOP)
  return grid
end

local function make_zones()
  local grid = gu.mk_grid(15, 24)
  local zones = {
    Zone(Tile.ZONE_PINK, {
      { 6, 22 },
      { 7, 22 },
      { 8, 22 },
    }),
    Zone(Tile.ZONE_PINK, {
      { 7, 13 },
      { 8, 13 },
      { 9, 13 },
    })
  }

  for _, zone in ipairs(zones) do
    print(zone.kind, zone.tiles)
    for _, xy in ipairs(zone.tiles) do
      grid.matrix[xy[1]][xy[2]] = Tile(zone.kind)
    end
  end

  return {
    grid = grid,
    zones = zones,
  }
end

local script = {}

script.entered = function(x, y, fromx, fromy, game)
  util.log('Entered {}, {} from {}, {}', x, y, fromx, fromy)
  local r, c = x + 1, y + 1
  local fr, fc = fromx + 1, fromy + 1
  if r == 10 and c == 23 then
    game.text = i18n.help_wheel
  end
  if fr == 10 and fc == 23 then
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

return { 
  grid = make_grid(),
  zones = make_zones(), 
  script = script
}
