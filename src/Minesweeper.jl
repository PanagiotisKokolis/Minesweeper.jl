module Minesweeper

using Logging
using Random
using StaticArrays
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2

logger = Base.SimpleLogger(stderr, Logging.Debug)
global_logger(logger)

# global variables, these are just for placeholding; change later
const WIN_WIDTH = 640
const WIN_HEIGHT = 720
const ttf_font_ref = Ref{Ptr{TTF_Font}}()
const textures = Dict{String, Tuple{Ptr{SDL_Surface}, Ptr{SDL_Texture}}}()

include("utils.jl")
include("render.jl")
include("game.jl")
include("engine.jl")

start_game()

end
