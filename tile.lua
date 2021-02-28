local Tile = {}
Tile.__index = Tile

setmetatable(Tile, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Tile.SIZE = 12

Tile.EMPTY = 'empty'
Tile.STONE = 'stone'
Tile.GREEN_FALLING = 'green-falling'
Tile.GREEN = 'green'
Tile.GREEN_EXP = 'green-exp'
Tile.ZONE_PINK = 'zone-pink'
Tile.ZONE_PINK_EXP = 'zone-pink-exp'
Tile.CONTROL_PANEL = 'control-panel'
Tile.CONVEYOR_LEFT = 'conveyor-left'
Tile.CONVEYOR_MID = 'conveyor-mid'
Tile.CONVEYOR_RIGHT = 'conveyor-right'
Tile.CONVEYOR_LEFT_CW = 'conveyor-left-cw'
Tile.CONVEYOR_MID_CW = 'conveyor-mid-cw'
Tile.CONVEYOR_RIGHT_CW = 'conveyor-right-cw'
Tile.CONVEYOR_LEFT_CCW = 'conveyor-left-ccw'
Tile.CONVEYOR_MID_CCW = 'conveyor-mid-ccw'
Tile.CONVEYOR_RIGHT_CCW = 'conveyor-right-ccw'


Tile.new = function(kind)
  local self = {}
  setmetatable(self, Tile)

  self.kind = kind
  self.frame = 0
  self.frames = 1
  self.frame_duration = 0
  self.t = 0
  self.loops = 0
  if kind == Tile.GREEN_FALLING then
    self.frames = 4
    self.frame_duration = 0.25
  elseif 
    kind == Tile.CONVEYOR_LEFT_CW or
    kind == Tile.CONVEYOR_MID_CW or 
    kind == Tile.CONVEYOR_RIGHT_CW or
    kind == Tile.CONVEYOR_LEFT_CCW or
    kind == Tile.CONVEYOR_MID_CCW or 
    kind == Tile.CONVEYOR_RIGHT_CCW 
    then
    self.frames = 3
    self.frame_duration = 0.16
  elseif kind == Tile.ZONE_PINK then
    self.frames = 3
    self.frame_duration = 0.32
  elseif kind == Tile.GREEN_EXP then
    self.frames = 4
    self.frame_duration = 0.16
    self.exploding = true
  elseif kind == Tile.ZONE_PINK_EXP then
    self.frames = 4
    self.frame_duration = 0.16
  end

  return self
end

Tile.texture_name = function(self)
  if self.kind == Tile.EMPTY then
    return nil
  elseif self.kind == Tile.STONE then
    return 'tile-stone'
  elseif self.kind == Tile.GREEN then
    return 'tile-green-1'
  elseif self.kind == Tile.GREEN_FALLING then
    if self.frame == 0 then
      return 'tile-green-0'
    elseif self.frame == 1 then
      return 'tile-green-1'
    elseif self.frame == 2 then
      return 'tile-green-2'
    elseif self.frame == 3 then
      return 'tile-green-1'
    end
  elseif self.kind == Tile.GREEN_EXP then
    return 'tile-green-exp-${f}' % { f = self.frame }
  elseif self.kind == Tile.ZONE_PINK then
    return 'tile-zone-pink-${f}' % { f = self.frame }
  elseif self.kind == Tile.ZONE_PINK_EXP then
    return 'tile-zone-pink-exp-${f}' % { f = self.frame }
  elseif self.kind == Tile.CONVEYOR_LEFT then
    return 'tile-conveyor-left-0'
  elseif self.kind == Tile.CONVEYOR_MID then
    return 'tile-conveyor-mid-0'
  elseif self.kind == Tile.CONVEYOR_RIGHT then
    return 'tile-conveyor-right-0'
  elseif self.kind == Tile.CONVEYOR_LEFT_CW then
    return 'tile-conveyor-left-${f}' % { f = self.frame }
  elseif self.kind == Tile.CONVEYOR_LEFT_CCW then
    return 'tile-conveyor-left-${f}' % { f = 2 - self.frame }
  elseif self.kind == Tile.CONVEYOR_MID_CW then
    return 'tile-conveyor-mid-${f}' % { f = self.frame }
  elseif self.kind == Tile.CONVEYOR_MID_CCW then
    return 'tile-conveyor-mid-${f}' % { f = 2 - self.frame }
   elseif self.kind == Tile.CONVEYOR_RIGHT_CW then
    return 'tile-conveyor-right-${f}' % { f = self.frame }
  elseif self.kind == Tile.CONVEYOR_RIGHT_CCW then
    return 'tile-conveyor-right-${f}' % { f = 2 - self.frame }
  elseif self.kind == Tile.CONTROL_PANEL then
    return 'tile-control-panel'
  end
  return nil
end

Tile.update = function(self, dt)
  if self.frames == 1 then
    return
  end

  self.t = self.t + dt
  if self.t >= self.frame_duration then
    if self.frame == self.frames - 1 then
      self.loops = self.loops + 1
    end
    self.frame = (self.frame + 1) % self.frames
    self.t = self.t - self.frame_duration
  end
end

Tile.embeds_to = function(self)
  if self.kind == Tile.GREEN_FALLING then
    return Tile.GREEN
  end
end

Tile.explodes_to = function(self)
  if self.kind == Tile.GREEN then
    return Tile.GREEN_EXP
  end
end

return Tile

