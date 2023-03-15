# structs and functionality that represent the gameplay of eating apples

"""
    Represents the game state of Eating Apples. This includes the 
    size of the game board, the entities contained and their states.
"""
struct EatingApplesGame
    width::Int
    height::Int
    entities::Vector{Entity} # to refine
end