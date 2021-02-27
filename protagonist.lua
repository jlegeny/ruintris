local Tile = require 'tile'

local Protagonist = {}
Protagonist.__index = Protagonist

setmetatable(Protagonist, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Protagonist.IDLE = 'idle'
Protagonist.WALK = 'walk'

Protagonist.LEFT = 'l'
Protagonist.RIGHT = 'r'

Protagonist.new = function()
  local self = {}
  setmetatable(self, Protagonist)

  self.state = Protagonist.IDLE
  self.direction = Protagonist.RIGHT
  self:set_animation(self.state)

  self.x = 0
  self.y = 0
  self.ox = 0
  self.oy = 0

  return self
end

Protagonist.set_animation = function(self, kind)
  if kind == Protagonist.IDLE then
    self.animation = {
      frame = 0,
      frames = 1,
      frame_duration = 0,
      t = 0,
    }
  elseif kind == Protagonist.WALK then
    self.animation = {
      frame = 0,
      frames = 4,
      frame_duration = 0.16,
      t = 0,
    }
  end
end

Protagonist.set_position = function(self, x, y, ox, oy)
  self.x = x
  self.y = y
  self.ox = ox
  self.oy = oy
end

Protagonist.texture_name = function(self)
  local dmod = 'r'
  if self.direction == Protagonist.LEFT then
    dmod = 'l'
  end

  if self.state == Protagonist.IDLE then
    return 'protagonist-idle-${d}' % {d = self.direction}
  elseif self.state == Protagonist.WALK then
    if self.animation.frame == 0 then
      return 'protagonist-step-${d}-0' % {d = self.direction}
    elseif self.animation.frame == 1 then
      return 'protagonist-step-${d}-1' % {d = self.direction}
    elseif self.animation.frame == 2 then
      return 'protagonist-step-${d}-2' % {d = self.direction}
    elseif self.animation.frame == 3 then
      return 'protagonist-step-${d}-3' % {d = self.direction}
    end
  end
  return nil
end

Protagonist.allowed_at = function(self, grid, x, y)
  if x < 0 or x > grid.width - 1 or y < 0 or y > grid.height - 1 then
    return false
  end

  if grid.matrix[x + 1][y + 1].kind ~= Tile.EMPTY then
    return false
  end
  print(x, y, grid.matrix[x + 1][y + 1].kind)

  return true
end

Protagonist.update = function(self, dt)
  if self.animation.frames == 1 then
    return
  end

  self.animation.t = self.animation.t + dt
  if self.animation.t >= self.animation.frame_duration then
    self.animation.frame = (self.animation.frame + 1) % self.animation.frames
    self.animation.t = self.animation.t - self.animation.frame_duration
  end
end

return Protagonist

