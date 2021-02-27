local util = require 'util'
local Tile = require 'tile'

local Renderer = {}
Renderer.__index = Renderer

setmetatable(Renderer, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Renderer.new = function(sprites)
  local self = {}
  setmetatable(self, Renderer)

  self.sprites = sprites

  return self
end

Renderer.resize = function(self, width, height)
  self.width = width
  self.height = height
  self.canvas = love.graphics.newCanvas(self.width, self.height)
  self.canvas:setFilter('nearest', 'nearest')
end

Renderer._draw_matrix = function(self, matrix, ox, oy)
  for c, column in ipairs(matrix) do
    for r, tile in ipairs(column) do
      local texture = tile:texture_name()
      if texture then
        local tx = (c - 1) * Tile.SIZE + ox
        local ty = (r - 1) * Tile.SIZE + oy
        love.graphics.draw(self.sprites:get(texture).texture, tx, ty)
      end
    end
  end
end

Renderer.draw = function(self, game, dt)
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()

  -- draw the grid

  util.set_color()
  local ox = math.floor((self.width - game.grid.width * Tile.SIZE) / 2)
  local oy = math.floor((self.height - game.grid.height * Tile.SIZE) / 2)
  self:_draw_matrix(game.grid.matrix, ox, oy)

  -- draw the falling piece
  if game.falling_piece then
    local ox = math.floor((self.width - game.grid.width * Tile.SIZE) / 2) + game.falling_piece.x * Tile.SIZE
    local oy = math.floor((self.height - game.grid.height * Tile.SIZE) / 2) + game.falling_piece.y * Tile.SIZE
    self:_draw_matrix(game.falling_piece.grid.matrix, ox, oy)
  end

  love.graphics.setCanvas()

  local draw_width, draw_height = love.graphics.getDimensions()
  local mw = draw_width / self.width
  local mh = draw_height / self.height
  love.graphics.draw(self.canvas, 0.5, 0.5, 0, mw, mh)
end

return Renderer
