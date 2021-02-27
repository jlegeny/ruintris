local Game = {}
Game.__index = Game

local INPUT_TICK_DURATION = 0.16
local TICK_DURATION = 1

setmetatable(Game, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Game.new = function(grid)
  local self = {}
  setmetatable(self, Game)

  self.grid = grid
  self.falling_piece = nil
  self.input_gating = 0

  return self
end

Game.add_falling_piece = function (self, piece)
  if self.falling_piece then
    io.stderr:write('A piece is already falling')
    love.event.quit(1)
  end
  self.falling_piece = piece
end

Game.tick = function(self)
end

Game.update = function(self, dt)
  self.input_gating = self.input_gating + dt
  -- controls
  if self.falling_piece then
    if self.input_gating >= INPUT_TICK_DURATION then
      if love.keyboard.isScancodeDown('left') then
        self.falling_piece.x = self.falling_piece.x - 1
      elseif love.keyboard.isScancodeDown('right') then
        self.falling_piece.x = self.falling_piece.x + 1
      end
      self.input_gating = self.input_gating - INPUT_TICK_DURATION
    end
  end

  self.grid:update(dt)
  if self.falling_piece then
    self.falling_piece.grid:update(dt)
  end
end

Game.keypressed = function(self, key, unicode)
end

return Game
