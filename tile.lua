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
Tile.CONTROL_PANEL = 'control-panel'
Tile.CONVEYOR_LEFT = 'conveyor-left'
Tile.CONVEYOR_MID = 'conveyor-mid'
Tile.CONVEYOR_RIGHT = 'conveyor-right'
Tile.CONVEYOR_LEFT_CW = 'conveyor-left-cw'
Tile.CONVEYOR_MID_CW = 'conveyor-mid-cw'
Tile.CONVEYOR_RIGHT_CW = 'conveyor-right-cw'


Tile.new = function(kind)
  local self = {}
  setmetatable(self, Tile)

  self.kind = kind
  self.frame = 0
  self.frames = 1
  self.frame_duration = 0
  self.t = 0
  if kind == Tile.GREEN_FALLING then
    self.frames = 4
    self.frame_duration = 0.25
  elseif kind == Tile.CONVEYOR_LEFT_CW or kind == Tile.CONVEYOR_MID_CW or kind == Tile.CONVEYOR_RIGHT_CW then
    self.frames = 3
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
  elseif self.kind == Tile.CONVEYOR_LEFT then
    return 'tile-conveyor-left-0'
  elseif self.kind == Tile.CONVEYOR_MID then
    return 'tile-conveyor-mid-0'
  elseif self.kind == Tile.CONVEYOR_RIGHT then
    return 'tile-conveyor-right-0'
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
    self.frame = (self.frame + 1) % self.frames
    self.t = self.t - self.frame_duration
  end
end

Tile.transforms_to = function(self)
  if self.kind == Tile.GREEN_FALLING then
    return Tile.GREEN
  end
end

return Tile

