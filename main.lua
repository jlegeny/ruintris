local util = require 'util'

local Game = require 'game'
local Menu = require 'menu'
local Catalog = require 'catalog'

local Piece = require 'piece'

local Background = require 'background'
local Renderer = require 'renderer'
local Overlay = require 'overlay'
local Hallway = require 'hallway'

local level01 = require 'levels/level01'

-- CONSTANTS

util.debug = true

local WINDOW_WIDTH = 960
local WINDOW_HEIGHT = 720
local RENDER_WIDTH = WINDOW_WIDTH / 2
local RENDER_HEIGHT = WINDOW_HEIGHT / 2

-- OBJECTS

local background_sprites = Catalog(Catalog.backgrounds)
local tile_sprites = Catalog(Catalog.tiles)
local sprites = Catalog(Catalog.sprites)

local menu = Menu({level01})
local hallway = Hallway(sprites)

local game = Game(level01)
local background = Background(background_sprites)
local renderer = Renderer(tile_sprites, sprites)
local overlay = Overlay(sprites)

-- LOVE ROUTINES

local State = {
  MENU = 'menu',
  IN_GAME = 'in-game',
}

function love.load()
  love.window.setTitle("Ruintris")
  love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, 
  {
    fullscreen = false, 
    vsync = true, 
    resizable = true, 
    minwidth = WINDOW_WIDTH, 
    minheight = WINDOW_HEIGHT
  })
  local font = love.graphics.newImageFont('assets/font.png',
  ' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`_*#=[]\'{}', 1) 
  love.graphics.setFont(font)

  background:set('bg-menu')
  hallway:resize(RENDER_WIDTH, RENDER_HEIGHT)
  background:resize(RENDER_WIDTH, RENDER_HEIGHT)
  renderer:resize(RENDER_WIDTH, RENDER_HEIGHT)
  overlay:resize(RENDER_WIDTH, RENDER_HEIGHT)

  game.protagonist:set_position(4, 22, 0, 0)
  --game.protagonist:set_position(14, 13, 0, 0)
  game.text = 'Press [escape] any time to restart the level. Press [q] to quit.'
end

function love.keypressed(key, unicode)
  if util.debug then
    if key == 'r' then
      love.event.quit('restart')
    elseif key == 'p' then
      local piece = Piece(Piece.L_RIGHT, Piece.GREEN)
      piece:set_position(6, 4)
      piece:make_controlled()
      game:add_falling_piece(piece)
      game.state = Game.CTRL_FALLING_PIECE
    elseif key == 'o' then
      local piece = Piece(Piece.S_LEFT, Piece.GREEN)
      piece:set_position(math.random(1, 12), 4)
      table.insert(game.pieces, piece)
    elseif key == 'u' then
      local piece = Piece(Piece.L_RIGHT, Piece.GREEN)
      piece:set_position(5, 19)
      table.insert(game.pieces, piece)
    end
  else
    if key == 'escape' then
      love.load()
    elseif key == 'q' then
      love.event.quit()
    end
  end

  if state == State.MENU then
    menu:keypressed(key, unicode)
  elseif state == State.IN_GAME then
    game:keypressed(key, unicode)
  end
end

function love.draw()
  local dt = love.timer.getDelta()

  if state == State.Menu then
    menu:update(dt)

    background:draw(game, dt)
    hallway:draw(menu, dt)
  elseif state == State.IN_GAME then
    game:update(dt)

    background:draw(game, dt)
    renderer:draw(game, dt)
    overlay:draw(game, dt)
  end
end
