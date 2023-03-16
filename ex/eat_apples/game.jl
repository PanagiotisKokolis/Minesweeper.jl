# structs and functionality that represent the gameplay of eating apples

# 


function EatingApplesGame()
    return EatingApplesGame(12, 12, init_entities(), init_actions())
end

function init_entities()
    player = :PLAYER => Player(6, 6)
    return Dict(player)
end

function init_actions()
    return Tuple{Symbol, GameAction}[]
end

# UPDATE THE GAME ONE TICK ###########

# dispatch on the engine state
update!(state::PlayState) = update!(state.game)
update!(::EngineState) = nothing

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
        update!(game, get(game.entities, entity, nothing), action)
    end

    return
end

# put the update! method for deletion in game.jl since it's really game-related logic
function update!(game, entity::Entity, ::DeleteAction)
    # NOTE: this is an inefficient search to find the correct key. I could solve this 
    #    with dispatching on Symbol first, but I am reducing overall complexitiy at the cost
    #    of "good" runtime algorithms.
    try
        e_key = only(filter(p -> p[2] == entity, pairs(game.entities)))
        @debug "Deleting $(game.entities[e_key])"
        delete!(game.entities, e_key)
    catch e
        @debug "$e"
    end

    return
end