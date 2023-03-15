# entry point for eating apples.

using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2

include("utils.jl")
include("input.jl")
include("entities.jl")
include("game.jl")
include("engine.jl")

# GAME DESCRIPTION:

# Spawn the player in a grid along with "apples" located randomly on the grid.
# The player can move around the grid. When they move to a location with an apple, they eat it.
# After all the apples are eaten, the player wins. 
# There is a main menu and gameplay state.
# A counter tracks how many apples have been eaten since startup.

start_game()