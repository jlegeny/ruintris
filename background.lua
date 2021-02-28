local util = require 'util'

local Background = {}
Background.__index = Background

setmetatable(Background, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Background.new = function(sprites)
  local self = {}
  setmetatable(self, Background)

  self.sprites = sprites

  return self
end

Background.resize = function(self, width, height)
  self.width = width
  self.height = height
  self.static_canvas = love.graphics.newCanvas(self.width, self.height)
  self.dynamic_canvas = love.graphics.newCanvas(self.width, self.height)
  self.static_canvas:setFilter('nearest', 'nearest')
  self:pre_render()
end

Background.pre_render = function(self)
  love.graphics.setCanvas(self.static_canvas)
  love.graphics.clear()
  love.graphics.draw(self.sprites:get('bg01').texture, 0, 0)
  love.graphics.setCanvas()
end

Background.draw = function(self, game, dt)
  local draw_width, draw_height = love.graphics.getDimensions()
  local mw = draw_width / self.width
  local mh = draw_height / self.height
  love.graphics.setCanvas()
  love.graphics.draw(self.static_canvas, 0, 0, 0, mw, mh)
  love.graphics.draw(self.dynamic_canvas, 0, 0, 0, mw, mh)
end

return Background
