local Protagonist = require 'protagonist'
local Tile = require 'tile'

local Game = {}
Game.__index = Game

local INPUT_TICK_DURATION = 0.16
local TICK_DURATION = 1

setmetatable(Game, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Game.CTRL_PROTAGONIST = 'ctrl-protagonist'
Game.CTRL_FALLING_PIECE = 'ctrl-falling-piece'

Game.new = function(grid, protagonist)
  local self = {}
  setmetatable(self, Game)

  self.state = Game.CTRL_PROTAGONIST

  self.grid = grid
  self.protagonist = protagonist
  self.falling_piece = nil
  self.input_gating = 0
  self.next_move = nil
  self.t = 0

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
  if self.falling_piece then
    if self.falling_piece:allowed_at(self.grid, self.falling_piece.x, self.falling_piece.y + 1) then
      self.falling_piece.y = self.falling_piece.y + 1
    else
      for c, column in ipairs(self.falling_piece.grid.matrix) do
        for r, tile in ipairs(column) do
          if not (tile.kind == Tile.EMPTY) then
            self.grid.matrix[self.falling_piece.x + c][self.falling_piece.y + r] = Tile(tile.kind)
          end
        end
      end
      self.falling_piece = nil
    end
  end
end

Game.update = function(self, dt)
  self.input_gating = self.input_gating - dt
  -- controls
  if self.state == Game.CTRL_PROTAGONIST then
    if love.keyboard.isScancodeDown('right') then
      if self.protagonist.state ~= Protagonist.WALK then
        self.protagonist:set_animation(Protagonist.WALK)
      end
      self.protagonist.state = Protagonist.WALK
      self.protagonist.direction = Protagonist.RIGHT
    elseif love.keyboard.isScancodeDown('left') then
      if self.protagonist.state ~= Protagonist.WALK then
        self.protagonist:set_animation(Protagonist.WALK)
      end
      self.protagonist.state = Protagonist.WALK
      self.protagonist.direction = Protagonist.LEFT
    else
      self.protagonist.state = Protagonist.IDLE
    end
  elseif self.state == Game.CTRL_FALLING_PIECE and self.falling_piece then
    if love.keyboard.isScancodeDown('left') then
      if self.next_move == nil then
        self.input_gating = 0
      end
      self.next_move = 'piece-left'
    elseif love.keyboard.isScancodeDown('right') then
      if self.next_move == nil then
        self.input_gating = 0
      end
      self.next_move = 'piece-right'
    elseif love.keyboard.isScancodeDown('down') then
      if self.next_move == nil then
        self.input_gating = 0
      end
      self.next_move = 'piece-down'
    else
      self.next_move = nil
    end
    if self.input_gating <= 0 then
      if self.next_move == 'piece-left' then
        if self.falling_piece:allowed_at(self.grid, self.falling_piece.x - 1, self.falling_piece.y) then
          self.falling_piece.x = self.falling_piece.x - 1
        end
      elseif self.next_move == 'piece-right' then
        if self.falling_piece:allowed_at(self.grid, self.falling_piece.x + 1, self.falling_piece.y) then
          self.falling_piece.x = self.falling_piece.x + 1
        end
      elseif self.next_move == 'piece-down' then
        if self.falling_piece:allowed_at(self.grid, self.falling_piece.x, self.falling_piece.y + 1) then
          self.falling_piece.y = self.falling_piece.y + 1
        end
      end
      self.input_gating = INPUT_TICK_DURATION
    end
  end

  self.grid:update(dt)
  self.protagonist:update(dt)
  if self.falling_piece then
    self.falling_piece.grid:update(dt)
  end

  if self.protagonist.state == Protagonist.WALK then
    if self.protagonist.direction == Protagonist.RIGHT then
      self.protagonist.ox = self.protagonist.ox + 1
      if self.protagonist.ox >= Tile.SIZE / 2 then
        if self.protagonist:allowed_at(self.grid, self.protagonist.x + 1, self.protagonist.y) then
          self.protagonist.x = self.protagonist.x + 1
          self.protagonist.ox = self.protagonist.ox - Tile.SIZE
        else
          self.protagonist.state = Protagonist.IDLE
          self.protagonist.set_animation(Protagonist.IDLE)
          self.protagonist.ox = Tile.SIZE / 2 - 1
        end
      end
    elseif self.protagonist.direction == Protagonist.LEFT then
      self.protagonist.ox = self.protagonist.ox - 1
      if self.protagonist.ox <=  -Tile.SIZE / 2 then
        if self.protagonist:allowed_at(self.grid, self.protagonist.x - 1, self.protagonist.y) then
          self.protagonist.x = self.protagonist.x - 1
          self.protagonist.ox = self.protagonist.ox + Tile.SIZE
        else
          self.protagonist.state = Protagonist.IDLE
          self.protagonist.set_animation(Protagonist.IDLE)
          self.protagonist.ox = -Tile.SIZE / 2 + 1
        end
      end
     end
  end

  self.t = self.t + dt
  if self.t >= TICK_DURATION then
    self.t = self.t - TICK_DURATION
    self:tick()
  end
end

Game.keypressed = function(self, key, unicode)
end

return Game
