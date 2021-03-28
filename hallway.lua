local gu = require 'gameutil'
local util = require 'util'
local Scroll = require 'scroll'

local Hallway = {}
Hallway.__index = Hallway

setmetatable(Hallway, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

local ITEM_HEIGHT = 20

Hallway.new = function(sprites)
  local self = {}
  setmetatable(self, Hallway)

  self.sprites = sprites

  self.scroll = Scroll(sprites, 'vertical', 240, 180, 200, 200)

  return self
end

Hallway.resize = function(self, width, height)
  self.scroll:resize(width, height)

  self.width = width
  self.height = height
  self.static_canvas = love.graphics.newCanvas(self.width, self.height)
  self.static_canvas:setFilter('nearest', 'nearest')
  self.dynamic_canvas = love.graphics.newCanvas(self.width, self.height)
  self.dynamic_canvas:setFilter('nearest', 'nearest')
  self:pre_render()
end

Hallway.pre_render = function(self)
  self.scroll:pre_render()
  love.graphics.setCanvas(self.static_canvas)
  love.graphics.clear()
  love.graphics.setCanvas()
end

Hallway.update = function(self, dt)
  self.scroll:update(dt)
end

Hallway.draw = function(self, menu)
  love.graphics.setCanvas(self.dynamic_canvas)
  love.graphics.clear()

  gu.set_color('eggplant', 0)
  love.graphics.rectangle('line', 140.5, 150.5 + menu.selected * ITEM_HEIGHT, 200, ITEM_HEIGHT)

  
  gu.set_color()

  for i, option in ipairs(menu.options) do
    love.graphics.printf(option.title, 0, 150 + (i - 1) * ITEM_HEIGHT, 480, 'center')
  end

  local draw_width, draw_height = love.graphics.getDimensions()
  local mw = draw_width / self.width
  local mh = draw_height / self.height
  self.scroll:draw(menu, dt)
  love.graphics.setCanvas()
  love.graphics.draw(self.static_canvas, 0, 0, 0, mw, mh)
  love.graphics.draw(self.dynamic_canvas, 0, 0, 0, mw, mh)
end

return Hallway
