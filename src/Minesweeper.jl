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

include("utils.jl")
include("game.jl")
include("engine.jl")

start_game()

end
