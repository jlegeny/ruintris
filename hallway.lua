local util = require 'util'
local Scroll = require 'scroll'

local Hallway = {}
Hallway.__index = Hallway

setmetatable(Hallway, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Hallway.new = function(sprites)
  local self = {}
  setmetatable(self, Hallway)

  self.sprites = sprites

  self.scroll = Scroll(sprites, 'horizontal', 240, 180, 200, 200)

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

Hallway.draw = function(self, menu, dt)
  local draw_width, draw_height = love.graphics.getDimensions()
  local mw = draw_width / self.width
  local mh = draw_height / self.height
  love.graphics.setCanvas()
  self.scroll:draw(menu, dt)
  love.graphics.draw(self.static_canvas, 0, 0, 0, mw, mh)
  love.graphics.draw(self.dynamic_canvas, 0, 0, 0, mw, mh)
end

return Hallway
