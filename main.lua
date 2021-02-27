local Game = require 'game'
local Catalog = require 'catalog'

local Piece = require 'piece'

local Background = require 'background'
local Renderer = require 'renderer'
local Overlay = require 'overlay'

local grid01 = require 'grids/grid01'

-- CONSTANTS

local debug = true

local WINDOW_WIDTH = 960
local WINDOW_HEIGHT = 720
local RENDER_WIDTH = WINDOW_WIDTH / 2
local RENDER_HEIGHT = WINDOW_HEIGHT / 2

-- OBJECTS

local background_sprites = Catalog(Catalog.backgrounds)
local tile_sprites = Catalog(Catalog.tiles)
local game = Game(grid01)
local background = Background(background_sprites)
local renderer = Renderer(tile_sprites)
local overlay = Overlay()

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
  background:resize(RENDER_WIDTH, RENDER_HEIGHT)
  renderer:resize(RENDER_WIDTH, RENDER_HEIGHT)
  overlay:resize(RENDER_WIDTH, RENDER_HEIGHT)

  local piece = Piece(Piece.L_RIGHT, Piece.GREEN)
  game:add_falling_piece(piece)
end

function love.keypressed(key, unicode)
  if key == 'r' and debug then
    love.event.quit('restart')
  end

  game:keypressed(key, unicode)
end

function love.draw()
  local dt = love.timer.getDelta()

  game:update(dt)

  --background:draw(game, dt)
  renderer:draw(game, dt)
  overlay:draw(game, dt)
end
