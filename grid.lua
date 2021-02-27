local Grid = {}
Grid.__index = Grid

setmetatable(Grid, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Grid.new = function(width, height, matrix)
  local self = {}
  setmetatable(self, Grid)

  self.width = width
  self.height = height
  self.matrix = matrix

  return self
end

Grid.update = function(self, dt)
  for c, column in ipairs(self.matrix) do
    for r, tile in ipairs(column) do
      tile:update(dt)
    end
  end
end

return Grid

