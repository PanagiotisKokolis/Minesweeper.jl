# structs and functionality that represent the gameplay of eating apples

# 
@enum Direction begin
    DIR_UP=1
    DIR_LEFT=2
    DIR_RIGHT=3
    DIR_DOWN=4
end

"""
    GameAction

The supertype of all gameplay actions. These are actions taken by the 
Entities of the game.
"""
abstract type GameAction end

struct MoveAction <: GameAction
    direction::Direction
end

"""
    Represents the game state of Eating Apples. This includes the 
    size of the game board, the entities contained and their states.
"""
struct EatingApplesGame
    width::Int
    height::Int
    entities::Dict{Symbol, Entity} # to refine
    actions::Vector{Tuple{Symbol, GameAction}} # to refine
end
function EatingApplesGame()
    return EatingApplesGame(12, 12, init_entities(), init_actions())
end

function init_entities()
    return Dict{Symbol, Entity}()
end

function init_actions()
    return Tuple{Symbol, GameAction}[]
end

# UPDATE THE GAME ONE TICK ###########

function update!(game::EatingApplesGame)

    # for each tick of the game, we want to resolve all GameActions 
    # "simultaneously" to transition the game from one frame to the next.
    # 
    # Some questions remain: how to handle entity creation/deletion elegantly ?
    # Should we create more Actions in update! ?
    # Should we allow callbacks ? Should we keep created actions in a separate, new
    # list ? As callbacks ? And then parse them all after game.actions is empty ?
    #  - What if those callbacks create actions ? HMMMM Beware infinite loop

    while !isempty(game.actions)
        entity, action = popfirst!(game.actions)
        update!(game, entities[entity], action)
    end

