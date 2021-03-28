local util = require 'util'

local Menu = {}
Menu.__index = Menu

setmetatable(Menu, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Menu.MAIN = 'main'
Menu.LEVEL_SELECT = 'level-select'

local main_options = {
  {
    title = 'new game',
    id = 'new-game'
  },
  {
    title = 'level select',
    id = 'level-select',
  },
  {
    title = 'credits',
    id = 'credits',
  },
  {
    title = 'quit',
    id = 'quit',
  }
}

Menu.new = function(levels)
  local self = {}
  setmetatable(self, Menu)

  self.levels = levels
  self.state = Menu.MAIN

  self.selected = 0
  self.options = main_options
  self.selected_stack = { self.selected }

  return self
end

Menu.activate = function(self, id)
  util.log('{}', id)
  if id == 'back' then
    self:back()
    return
  end
  if self.state == Menu.MAIN then
    if id == 'level-select' then
      table.insert(self.selected_stack, self.selected)
      self.selected = 0
      self.state = Menu.LEVEL_SELECT
      self.options = {}
      for i, level in ipairs(self.levels) do
        table.insert(self.options, {
          title = string.format("%02d %s", i, level.name),
          id = i,
        })
      end
      table.insert(self.options, 
        {
          title = 'back',
          id = 'back',
        }
      )
    end
  end
end

Menu.back = function(self)
  if self.state == Menu.MAIN then
    self.selected = 0
  elseif self.state == Menu.LEVEL_SELECT then
    self.state = Menu.MAIN
    self.options = main_options
    self.selected = self.selected_stack[#self.selected_stack]
    table.remove(self.selected_stack, #self.selected_stack)
  end
end

Menu.update = function(self, dt)
end

Menu.keypressed = function(self, key, unicode)
  print(key)
  if key == 'down' then
    self.selected = (self.selected + 1) % #self.options
  elseif key == 'up' then
    self.selected = (self.selected - 1) % #self.options
  elseif key == 'return' then
    self:activate(self.options[self.selected + 1].id)
  elseif key == 'escape' then
    self:back()
  end
end

return Menu


