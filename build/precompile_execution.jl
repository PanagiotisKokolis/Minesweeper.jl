# in order to speed up execution of our binary, we can precompile 
# the functions ahead of time. 
# Only the specific methods that are called in this script will be precompiled,
# so we need to call all the methods we want to precompile.

using Minesweeper

# precompile the game creation function
Minesweeper.create_game(:easy)
Minesweeper.create_game(:intermediate)
Minesweeper.create_game(:expert)

