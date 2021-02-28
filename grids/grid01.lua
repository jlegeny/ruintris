local util = require 'util'
local gu = require 'gameutil'

local Tile = require 'tile'
local Piece = require 'piece'
local Game = require 'game'
local Zone = require 'zone'

local function entered(x, y, fromx, fromy, game)
  util.log('Entered {}, {} from {}, {}', x, y, fromx, fromy)
  local r, c = x + 1, y + 1
  local fr, fc = fromx + 1, fromy + 1
  if r == 10 and c == 23 then
    game.text = 'Press [space] to interact with the wheel. Press [space] again to go back to exploring.'
  end
  if fr == 10 and fc == 23 then
    game.text = ''
  end
end

local function trigger(x, y, game)
  util.log('Triggered tile at {}, {}', x, y)
  local tile_at = game.grid.matrix[x + 1][y + 1]
  -- CONTROL_PANELS
  if tile_at.kind == Tile.CONTROL_PANEL then
    if game.state == Game.CTRL_PROTAGONIST then
      game.state = Game.CTRL_CONVEYOR
      game.text = 'Use arrows to move conveyor belt [left] or [right] to choose the piece. Press [space] to go back to exploring.'
    elseif game.state == Game.CTRL_CONVEYOR then
      game.state = Game.CTRL_PROTAGONIST
      game.text = 'Press [space] to interact with the wheel. Press [space] again to go back to exploring.'
      game.script.conveyor(Game.STOP, game)
    end
    --local piece = Piece(Piece.L_RIGHT, Piece.GREEN)
    --piece:set_position(6, 0) 
    --game:add_falling_piece(piece)
  end
end

local function covered(x, y, game)
end

local function uncovered(x, y, game)
end

local function set_conveyor(matrix, direction)
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

local function conveyor(direction, game)
  util.log('Conveyor turining {}', direction)
  if direction == Game.LEFT then
    set_conveyor(game.grid.matrix, Game.LEFT)
  elseif direction == Game.RIGHT then
    set_conveyor(game.grid.matrix, Game.RIGHT)
  elseif direction == Game.STOP then
    set_conveyor(game.grid.matrix, Game.STOP)
  end
end

local function make_grid()
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

  grid.matrix[6][23] = Tile(Tile.STONE)
  grid.matrix[7][23] = Tile(Tile.STONE)
  grid.matrix[8][23] = Tile(Tile.STONE)


  grid.matrix[10][23] = Tile(Tile.CONTROL_PANEL)

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

local script = {
  entered = entered,
  trigger = trigger,
  covered = covered,
  conveyor = conveyor,
  uncovered = uncovered,
}

return { 
  grid = make_grid(),
  zones = make_zones(), 
  script = script
}
