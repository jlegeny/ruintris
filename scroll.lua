local util = require 'util'
local gu = require 'gameutil'

local Scroll = {}
Scroll.__index = Scroll

local LEFT = 49
local TOP = 38
local TILE_W = 12
local TILE_H = 22
local RIGHT = 46
local BOTTOM = 26

setmetatable(Scroll, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Scroll.new = function(sprites, orientation, x, y, width, height)
  local self = {}
  setmetatable(self, Scroll)

  self.sprites = sprites
  self.x = x
  self.y = y

  self.orientation = orientation
  if orientation == 'horizontal' then
    self.w = width
    self.h = height
    self.cw = 0
    self.ch = height
    self.animates = true
  elseif orientation == 'vertical' then
    self.w = height
    self.h = width
    self.cw = 0
    self.ch = width
    self.animates = true
  else
    gu.panic('Unknown scroll orientation "{}"', orientation)
  end


  return self
end

Scroll.resize = function(self, width, height)
  self.width = width
  self.height = height
  self.static_canvas = love.graphics.newCanvas(self.width, self.height)
  self.static_canvas:setFilter('nearest', 'nearest')
  self:pre_render()
end

Scroll.pre_render = function(self)
  love.graphics.setCanvas(self.static_canvas)
  love.graphics.clear()

  local ox = self.x - self.cw / 2
  local oy = self.y - self.ch / 2

  love.graphics.draw(self.sprites:get('scroll-7').texture, ox - LEFT, oy - TOP)
  love.graphics.draw(self.sprites:get('scroll-1').texture, ox - LEFT, oy + self.ch)
  love.graphics.draw(self.sprites:get('scroll-9').texture, ox + self.cw, oy - TOP)
  love.graphics.draw(self.sprites:get('scroll-3').texture, ox + self.cw, oy + self.ch)
  
  local top_tile = self.sprites:get('scroll-8').texture
  local bottom_tile = self.sprites:get('scroll-2').texture
  local i = 0
  while i < math.floor(self.cw / TILE_W) do
    love.graphics.draw(top_tile, ox + i * TILE_W, oy - TOP)
    love.graphics.draw(bottom_tile, ox + i * TILE_W, oy + self.ch)
    i = i + 1
  end

  if self.cw % TILE_W ~= 0 then
    local lw = self.cw % TILE_W
    love.graphics.setScissor(ox + i * TILE_W, oy - TOP, lw, TOP + self.ch + BOTTOM)
    love.graphics.draw(top_tile, ox + i * TILE_W, oy - TOP)
    love.graphics.draw(bottom_tile, ox + i * TILE_W, oy + self.ch)
    love.graphics.setScissor()
  end

  local left_tile = self.sprites:get('scroll-4').texture
  local right_tile = self.sprites:get('scroll-6').texture
  local i = 0
  while i < math.floor(self.ch / TILE_H) do
    love.graphics.draw(left_tile, ox - LEFT, oy + i * TILE_H)
    love.graphics.draw(right_tile, ox + self.cw, oy + i * TILE_H)
    i = i + 1
  end

  if self.ch % TILE_H ~= 0 then
    local lh = self.ch % TILE_H
    love.graphics.setScissor(ox - LEFT, oy + i * TILE_H , LEFT + self.cw + RIGHT, lh)
    love.graphics.draw(left_tile, ox - LEFT, oy + i * TILE_H)
    love.graphics.draw(right_tile, ox + self.cw, oy + i * TILE_H)
    love.graphics.setScissor()
  end

  gu.set_color('eggplant', 7)
  love.graphics.rectangle('fill', ox, oy, self.cw, self.ch)
  gu.set_color()

  love.graphics.setCanvas()
end

Scroll.update = function(self, dt)
  if self.cw < self.w then
    self.cw = math.ceil(self.cw + 400 * dt)
    if self.cw > self.w then
      self.cw = self.w
    end
    self:pre_render()
  else
    self.animates = false
  end
end

Scroll.draw = function(self, menu)
  local draw_width, draw_height = love.graphics.getDimensions()
  local mw = draw_width / self.width
  local mh = draw_height / self.height
  love.graphics.setCanvas()
  local r = 0
  if self.orientation == 'vertical' then
    r = math.pi / 2
  end
  love.graphics.draw(self.static_canvas, self.width, self.height, r, mw, mh, self.width / 2, self.height / 2)
end

return Scroll
