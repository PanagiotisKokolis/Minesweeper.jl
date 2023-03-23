module Minesweeper

using Logging
using Random
using StaticArrays
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2

logger = Base.SimpleLogger(stderr, Logging.Debug)
global_logger(logger)

include("utils.jl")
include("text.jl")

# global variables, these are just for placeholding; change later
const WIN_WIDTH = 640
const WIN_HEIGHT = 720
const font_mgr = Dict{String, FontManager}()
const textures = Dict{String, TextDrawable}()

include("game.jl")
include("engine.jl")
include("input.jl")
include("render.jl")

# start_game()

end
