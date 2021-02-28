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
Protagonist.HOIST = 'hoist'
Protagonist.START_FALL = 'start-fall'
Protagonist.FALL = 'fall'
Protagonist.LAND = 'land'
Protagonist.SQUISHED = 'squished'

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
  elseif kind == Protagonist.HOIST then
    self.animation = {
      frame = 0,
      frames = 4,
      frame_duration = 0.16,
      t = 0,
    }
  elseif kind == Protagonist.START_FALL then
    self.animation = {
      frame = 0,
      frames = 3,
      frame_duration = 0.16,
      t = 0,
     }
  elseif kind == Protagonist.FALL then
    self.animation = {
      frame = 0,
      frames = 2,
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

Protagonist.has_control = function(self)
  return self.state == Protagonist.IDLE or self.state == Protagonist.WALK
end

Protagonist.set_squish = function(self, is_squished)
  if is_squished then
    self.state = Protagonist.SQUISHED
  end
end

Protagonist.texture_name = function(self)
  local dmod = 'r'
  if self.direction == Protagonist.LEFT then
    dmod = 'l'
  end

  if self.state == Protagonist.IDLE then
    return 'protagonist-idle-${d}' % {d = self.direction}
  elseif self.state == Protagonist.WALK then
    return 'protagonist-step-${d}-${f}' % {d = self.direction, f = self.animation.frame}
  elseif self.state == Protagonist.HOIST then
    return 'protagonist-hoist-${d}-${f}' % {d = self.direction, f = self.animation.frame}
  elseif self.state == Protagonist.START_FALL then
    return 'protagonist-idle-${d}' % {d = self.direction}
  elseif self.state == Protagonist.FALL then
    return 'protagonist-idle-${d}' % {d = self.direction}
  elseif self.state == Protagonist.SQUISHED then
    return 'protagonist-squished'
  end
  return nil
end

Protagonist.allowed_at = function(self, grid, x, y)
  if x < 0 or x > grid.width - 1 or y < 0 or y > grid.height - 1 then
    return false
  end

  return grid:passable(x, y)
end

Protagonist.update = function(self, dt)
  if self.animation.frames == 1 then
    return
  end

  self.animation.t = self.animation.t + dt
  if self.animation.t >= self.animation.frame_duration then
    if self.state == Protagonist.HOIST and self.animation.frame == self.animation.frames - 1 then
      self.state = Protagonist.IDLE
      self:set_animation(Protagonist.IDLE)
      if self.direction == Protagonist.RIGHT then
        self.x = self.x + 1
        self.y = self.y - 1
        self.ox = 0
      elseif self.direction == Protagonist.LEFT then
        self.x = self.x - 1
        self.y = self.y - 1
        self.ox = 0
      end
    elseif self.state == Protagonist.START_FALL then
      local pd = 1
      if self.direction == Protagonist.LEFT then
        pd = -1
      end
      if self.animation.frame == 0 then
        self.ox = self.ox + 2 * pd
        self.oy = self.oy + 1
      elseif self.animation.frame == 1 then
        self.ox = self.ox + 2 * pd
        self.oy = self.oy + 2
      elseif self.animation.frame == 2 then
        self.oy = self.oy + 2
        self.state = Protagonist.FALL
        self:set_animation(Protagonist.FALL)
      end
    end
    self.animation.frame = (self.animation.frame + 1) % self.animation.frames
    self.animation.t = self.animation.t - self.animation.frame_duration
  end

end

return Protagonist

