local util = require 'util'
local Tile = require 'tile'

local Overlay = {}
Overlay.__index = Overlay

setmetatable(Overlay, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Overlay.new = function(width, height)
  local self = {}
  setmetatable(self, Overlay)

  self:resize(width, height)

  return self
end

Overlay.resize = function(self, width, height)
  self.width = width
  self.height = height
  self.canvas = love.graphics.newCanvas(self.width, self.height)
  self.canvas:setFilter('nearest', 'nearest')
end

Overlay.draw = function(self, game, dt)
  love.graphics.setCanvas(self.canvas)

  love.graphics.setLineWidth(1)
  love.graphics.setLineStyle('rough')
  util.set_color('grey', 0)
  local ox = math.floor((self.width - game.grid.width * Tile.SIZE) / 2)
  local oy = math.floor((self.height - game.grid.height * Tile.SIZE) / 2)
  for r = 0, game.grid.height - 1 do
    for c = 0, game.grid.width - 1 do
      local tx = c * Tile.SIZE + 0.5 + ox
      local ty = r * Tile.SIZE + 0.5 + oy
      love.graphics.rectangle('line', tx, ty, Tile.SIZE, Tile.SIZE)
    end
  end
  util.set_color()

  love.graphics.setCanvas()

  local draw_width, draw_height = love.graphics.getDimensions()
  local mw = draw_width / self.width
  local mh = draw_height / self.height
  love.graphics.draw(self.canvas, 0, 0, 0, mw, mh)
end

return Overlay
