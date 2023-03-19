# entry point for eating apples.

using Random
using Logging
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2

logger = ConsoleLogger(stderr, Logging.Debug)
global_logger(logger)

# common definitions

# UPDATE THE GAME ONE TICK ###########
function update! end

function render end
function _render end

include("types.jl")
include("utils.jl")
include("entities.jl")
include("game.jl")
include("engine.jl")
include("render.jl")
include("input.jl")

# GAME DESCRIPTION:

# Spawn the player in a grid along with "apples" located randomly on the grid.
# The player can move around the grid. When they move to a location with an apple, they eat it.
# After all the apples are eaten, the player wins. 
# There is a main menu and gameplay state.
# A counter tracks how many apples have been eaten since startup.

start_game()