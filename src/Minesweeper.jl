module Minesweeper

using Logging
using Random
using StaticArrays
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2

logger = Base.SimpleLogger(stderr, Logging.Debug)
global_logger(logger)

include("game.jl")
include("engine.jl")

end
