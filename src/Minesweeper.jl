"""
    Minesweeper

A simple Minesweeper game written in Julia using SDL2.
"""
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
const font_mgr = Dict{String, FontManager}()
const textures = Dict{String, TextDrawable}()

include("game.jl")
include("engine.jl")
include("input.jl")
include("render.jl")
include("entry.jl")

end
