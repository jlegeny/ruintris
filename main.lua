local util = require 'util'

local Game = require 'game'
local Catalog = require 'catalog'

local Protagonist = require 'protagonist'
local Piece = require 'piece'

local Background = require 'background'
local Renderer = require 'renderer'
local Overlay = require 'overlay'

local grid01 = require 'grids/grid01'

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

local protagonist = Protagonist()
local game = Game(grid01, protagonist)
local background = Background(background_sprites)
local renderer = Renderer(tile_sprites, sprites)
local overlay = Overlay(sprites)

-- LOVE ROUTINES

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

  background:resize(RENDER_WIDTH, RENDER_HEIGHT)
  renderer:resize(RENDER_WIDTH, RENDER_HEIGHT)
  overlay:resize(RENDER_WIDTH, RENDER_HEIGHT)

  game.protagonist:set_position(10, 22, 0, 0)
  --game.protagonist:set_position(0, 0, 0, 0)
end

function love.keypressed(key, unicode)
  if util.debug then
    if key == 'r' then
      love.event.quit('restart')
    elseif key == 'p' then
      local piece = Piece(Piece.L_RIGHT, Piece.GREEN)
      piece:set_position(6, 4)
      game:add_falling_piece(piece)
      game.state = Game.CTRL_FALLING_PIECE
    elseif key == 'o' then
      local piece = Piece(Piece.S_LEFT, Piece.GREEN)
      piece:set_position(math.random(1, 12), 4)
      table.insert(game.pieces, piece)
    end
  end

  game:keypressed(key, unicode)
end

function love.draw()
  local dt = love.timer.getDelta()

  game:update(dt)

  --background:draw(game, dt)
  renderer:draw(game, dt)
  overlay:draw(game, dt)
  --
end
