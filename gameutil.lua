local util = require 'util'
local palette = require 'palette'

local Grid = require 'grid'
local Tile = require 'tile'

local gu = {}

gu.mk_grid = function(w, h)
  local matrix = {}

  for c = 1, w do
    matrix[c] = {}
    for r = 1, h do
      matrix[c][r] = Tile(Tile.EMPTY)
    end
  end

  return Grid(w, h, matrix)
end

gu.matrix_bounds = function(matrix)
  local w = #matrix[1]
  local h = #matrix

  local minx = w
  local maxx = 1
  local miny = h
  local maxy = 1

  for c, column in ipairs(matrix) do
    for r, tile in ipairs(column) do
      if not (tile.kind == Tile.EMPTY) then
        minx = math.min(minx, c)
        maxx = math.max(maxx, c)
        miny = math.min(miny, r)
        maxy = math.max(maxy, r)
      end
    end
  end
  return minx - 1, maxx - 1, miny - 1, maxy -1
end

gu.set_color = function(color, intensity)
  if color == nil and intensity == nil then
    love.graphics.setColor(1, 1, 1, 1)
  else
    love.graphics.setColor(unpack(palette[color][intensity]))
  end
end

gu.panic = function(template, ...)
  local args = {...}
  for i, v in ipairs(args) do
    template = template:gsub('{}', util.str(v), 1)
  end

  io.stderr:write(template .. '\n')
  love.event.quit(1)
end

return gu
