# structs and functionality that represent the gameplay of eating apples

# 


function EatingApplesGame()
    return EatingApplesGame(12, 12, init_entities(), init_actions())
end

function init_entities()
    player = :PLAYER => Player(6, 6)
    apple1 = :APPLE1 => Apple(2, 3, 0)
    apple2 = :APPLE2 => Apple(9, 9, 0)
    return Dict(player, apple1, apple2)
end

function init_actions()
    return Tuple{Symbol, GameAction}[]
end

# POLL THE ENTITY AI ABOUT WHAT ACTIONS TO PERFORM #
poll_ai(::EngineState) = return
function poll_ai(play::PlayState)
    game = play.game
    MAX_P = 120
    # for each apple, increment its patience
    # if patience passes a threshold, push a random move action to the game.
    for (e_key, entity) in game.entities
        # we could add more levels of dispatch here, but the logic is so simple
        # we will just use if-else
        if entity isa Apple
            # increment patience mod 120 (120 frames ≈ 2 seconds)
            entity.patience = (entity.patience + 1) % MAX_P
            if entity.patience == MAX_P - 1
                @debug "Patience reached for $entity !"
                push!(game.actions, (e_key, MoveAction(rand([DIR_UP, DIR_LEFT, DIR_RIGHT, DIR_DOWN]))))
            end
        end
    end
    return
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
        # NOTE: I think there is a conceptual difference between "pushing" an action REQUEST
        #   to an entity and actually UPDATING that entity according to all the game systems
        #   that are relevant to it (physics, incoming damage, player inputs, etc...)

        # In this game, I'm not separating these things, but I think I will in the future

        # Really, game.actions is actually game.events, which can continue Actions for entities
        # but also more generic events. Or maybe those should be separate? Designs designs...
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
        e_key = only(filter(p -> p[2] == entity, pairs(game.entities)))[1]
        @debug "Deleting $(game.entities[e_key])"
        delete!(game.entities, e_key)
    catch e
        @debug "$e"
    end

    return
end