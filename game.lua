local matrix = require 'matrix'

local Protagonist = require 'protagonist'
local Piece = require 'piece'
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
Game.CTRL_CONVEYOR = 'ctrl-conveyor'
Game.CTRL_FALLING_PIECE = 'ctrl-falling-piece'
Game.CTRL_NONE = 'ctrl-none'

Game.LEFT = 'left'
Game.RIGHT = 'right'
Game.STOP = 'stop'

Game.new = function(level, protagonist)
  local self = {}
  setmetatable(self, Game)

  self.state = Game.CTRL_PROTAGONIST

  self.grid = level.grid
  self.zones = level.zones
  self.script = level.script
  self.protagonist = protagonist
  self.falling_piece = nil
  self.pieces = {}
  self.input_gating = 0
  self.next_move = nil
  self.t = 0

  self.text = ''

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
      self.falling_piece:embed(self.grid.matrix)
      self.falling_piece = nil
      self.state = Game.CTRL_PROTAGONIST
    end
  end
  for _, piece in ipairs(self.pieces) do
    if piece:allowed_at(self.grid, piece.x, piece.y + 1) then
      piece.y = piece.y + 1
    else
      piece:embed(self.grid.matrix)
      piece.remove = true
    end
  end
  for i = #self.pieces, 1, -1 do
    if self.pieces[i].remove then
      self.pieces[i] = self.pieces[#self.pieces]
      self.pieces[#self.pieces] = nil
    end
  end

end

Game.update_protagonist = function(self, p)
  if p.state == Protagonist.WALK then
    if p.direction == Protagonist.RIGHT then
      p.ox = p.ox + 1
      if p.ox >= Tile.SIZE / 2 then
        if p:allowed_at(self.grid, p.x + 1, p.y) then
          p.x = p.x + 1
          p.ox = p.ox - Tile.SIZE
          if p:allowed_at(self.grid, p.x, p.y + 1) then
            p.state = Protagonist.START_FALL
            p.set_animation(Protagonist.START_FALL)
          end
        else
          if p:allowed_at(self.grid, p.x + 1, p.y - 1) then
            p.state = Protagonist.HOIST
            p.set_animation(Protagonist.HOIST)
          else
            p.state = Protagonist.IDLE
            p.set_animation(Protagonist.IDLE)
          end
          p.ox = Tile.SIZE / 2 - 1
        end
      end
    elseif p.direction == Protagonist.LEFT then
      p.ox = p.ox - 1
      if p.ox <=  -Tile.SIZE / 2 then
        if p:allowed_at(self.grid, p.x - 1, p.y) then
          p.x = p.x - 1
          p.ox = p.ox + Tile.SIZE
          if p:allowed_at(self.grid, p.x, p.y + 1) then
            p.state = Protagonist.START_FALL
            p.set_animation(Protagonist.START_FALL)
          end
        else
          if p:allowed_at(self.grid, p.x - 1, p.y - 1) then
            p.state = Protagonist.HOIST
            p.set_animation(Protagonist.HOIST)
          else
            p.state = Protagonist.IDLE
            p.set_animation(Protagonist.IDLE)
          end
          p.ox = -Tile.SIZE / 2 + 1
        end
      end
    end
  elseif p.state == Protagonist.FALL then
    p.oy = p.oy + 1
    if p.oy >= 0 then
      if p:allowed_at(self.grid, p.x, p.y + 1) then
        p.y = p.y + 1
        p.oy = p.oy - Tile.SIZE
      else
        p.state = Protagonist.IDLE
      end
    end
  end
end

Game.update_zones = function(self)
  for _, zone in ipairs(self.zones.zones) do
    zone:update(self)
  end
end

Game.post_explosion = function(self)
  local stencil = matrix.new(self.grid.width, self.grid.height)
  local solids = {}
  local volatiles = {}
  local parents = {}

  local next_id = 1

  for c, column in ipairs(self.grid.matrix) do
    for r, tile in ipairs(column) do
      if self.grid.matrix[c][r].kind ~= Tile.EMPTY then
        stencil[c][r] = next_id
        parents[next_id] = next_id
        next_id = next_id + 1
        if c > 1 and stencil[c - 1][r] ~= 0 then
          stencil[c][r] = stencil[c - 1][r]
        end
        if r > 1 and stencil[c][r - 1] then
          parents[stencil[c][r]] = stencil[c][r - 1]
        end
      end
    end
  end
end

Game.update = function(self, dt)
  self.input_gating = self.input_gating - dt
  -- controls
  if not self.protagonist:has_control() then
    goto skip_input
  end
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
  elseif self.state == Game.CTRL_CONVEYOR then
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

  ::skip_input::

  local pastx, pasty = self.protagonist.x, self.protagonist.y

  self.grid:update(dt)
  self.zones.grid:update(dt)
  self.protagonist:update(dt)
  if self.falling_piece then
    self.falling_piece.grid:update(dt)
  end

  for _, piece in ipairs(self.pieces) do
    piece.grid:update(dt)
  end

  self:update_zones()
  self:update_protagonist(self.protagonist)

  if pastx ~= self.protagonist.x or pasty ~= self.protagonist.y then
    self.script.entered(self.protagonist.x, self.protagonist.y, pastx, pasty, self)
  end

  self.t = self.t + dt
  if self.t >= TICK_DURATION then
    self.t = self.t - TICK_DURATION
    self:tick()
  end
end

Game.keypressed = function(self, key, unicode)
  key = love.keyboard.getScancodeFromKey(key)
  local shift = love.keyboard.isScancodeDown('lshift')
  if self.state == Game.CTRL_CONVEYOR then
    if key == 'right' then
      self.script.conveyor(Game.RIGHT, self)
    elseif key == 'left' then
      self.script.conveyor(Game.LEFT, self)
    end
  elseif self.state == Game.CTRL_FALLING_PIECE then
    if key == 'return' and shift then
      self.falling_piece:rotate(Piece.CCW)
    elseif key == 'return' then
      self.falling_piece:rotate(Piece.CW)
    end
  end
  
  if self.protagonist.state == Protagonist.IDLE then
    if key == 'space' then
      self.script.trigger(self.protagonist.x, self.protagonist.y, self)
    end
  end
end

return Game
