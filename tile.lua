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
Tile.GREEN = 'green'

Tile.new = function(kind)
  local self = {}
  setmetatable(self, Tile)

  self.kind = kind
  self.frame = 0
  self.frames = 1
  self.frame_duration = 0
  self.t = 0
  if kind == Tile.GREEN then
    self.frames = 4
    self.frame_duration = 0.25
  end

  return self
end

Tile.texture_name = function(self)
  if self.kind == Tile.EMPTY then
    return nil
  elseif self.kind == Tile.STONE then
    return 'tile-stone'
  elseif self.kind == Tile.GREEN then
    if self.frame == 0 then
      return 'tile-green-0'
    elseif self.frame == 1 then
      return 'tile-green-1'
    elseif self.frame == 2 then
      return 'tile-green-2'
    elseif self.frame == 3 then
      return 'tile-green-1'
    end
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

return Tile

