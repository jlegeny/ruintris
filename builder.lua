local Tile = require 'tile'

local builder = {}

builder.char_to_tile = {
  [' '] = Tile.EMPTY,
  ['#'] = Tile.STONE,
  ['v'] = Tile.CONTROL_PANEL,
  ['x'] = Tile.DOOR_TOP,
  ['X'] = Tile.DOOR_BOTTOM,
  ['('] = Tile.CONVEYOR_LEFT,
  ['O'] = Tile.CONVEYOR_MID,
  [')'] = Tile.CONVEYOR_RIGHT,
}

builder.initial_grid = function(level_str, marker_tiles)
  local h = #level_str
  local w = #level_str[1]
  local grid = gu.mk_grid(w, h)

  for r, row in ipairs(level_str) do
    for c = 1, #row do
      local t = row:sub(c, c)
      if t >= '0' and t <= '9' then
        t = marker_tiles[t]
        grid.add_marker(r, c, t - '0')
      end
      grid.matrix[c][r] = Tile(builder.char_to_tile[t])
    end
  end
end

return builder

