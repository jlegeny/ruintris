local Game = {}
Game.__index = Game

setmetatable(Game, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

Game.new = function(grid)
  local self = {}
  setmetatable(self, Game)

  self.grid = grid

  return self
end

return Game
