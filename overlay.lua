local gu = require 'gameutil'
local util = require 'util'
local Game = require 'game'
local Tile = require 'tile'

local Overlay = {}
Overlay.__index = Overlay

setmetatable(Overlay, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Overlay.new = function(sprites)
  local self = {}
  setmetatable(self, Overlay)
 
  self.sprites = sprites

  return self
end

Overlay.resize = function(self, width, height)
  self.width = width
  self.height = height
  self.static_canvas = love.graphics.newCanvas(self.width, self.height)
  self.static_canvas:setFilter('nearest', 'nearest')
  self.canvas = love.graphics.newCanvas(self.width, self.height)
  self.canvas:setFilter('nearest', 'nearest')
  self:pre_render()
end

Overlay.pre_render = function(self)
  love.graphics.setCanvas(self.static_canvas)
  love.graphics.clear()
  gu.set_color()
  love.graphics.draw(self.sprites:get('scroll').texture, 0, 283)
  love.graphics.setCanvas()
end

Overlay.draw = function(self, game, dt)
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()

  local midscroll = false

  if game.state == Game.GAME_OVER then
    gu.set_color()
    love.graphics.draw(self.sprites:get('scroll').texture, 0, 120)
    love.graphics.printf('GAME OVER', 0, 155, 480, 'center')
    midscroll = true
  elseif game.state == Game.WINNER then
    gu.set_color()
    love.graphics.draw(self.sprites:get('scroll').texture, 0, 120)
    love.graphics.printf('Thank you for playing.\nMade by yozy for the 11th Alakajam', 0, 150, 480, 'center')
    midscroll = true
  end

  --love.graphics.setLineWidth(1)
  --love.graphics.setLineStyle('rough')
  --gu.set_color('grey', 0)
  --local ox = math.floor((self.width - game.grid.width * Tile.SIZE) / 2)
  --local oy = math.floor((self.height - game.grid.height * Tile.SIZE - 58))
  --for r = 0, game.grid.height - 1 do
    --for c = 0, game.grid.width - 1 do
      --local tx = c * Tile.SIZE + 0.5 + ox
      --local ty = r * Tile.SIZE + 0.5 + oy
      --love.graphics.rectangle('line', tx, ty, Tile.SIZE, Tile.SIZE)
    --end
  --end

  --gu.set_color('red', 0)
  --local px = game.protagonist.x * Tile.SIZE + 0.5 + ox
  --local py = game.protagonist.y * Tile.SIZE + 0.5 + oy
  --love.graphics.rectangle('line', px, py, Tile.SIZE, Tile.SIZE)
  --gu.set_color()

  if not midscroll then
    if game.text ~= '' then
      love.graphics.printf(game.text, 50, 310, 380, 'left')
    end
  end

  local draw_width, draw_height = love.graphics.getDimensions()
  local mw = draw_width / self.width
  local mh = draw_height / self.height
  love.graphics.setCanvas()
  if not midscroll then
    love.graphics.draw(self.static_canvas, 0, 0, 0, mw, mh)
  end
  love.graphics.draw(self.canvas, 0, 0, 0, mw, mh)
end

return Overlay
