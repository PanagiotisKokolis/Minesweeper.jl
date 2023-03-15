
# this game consists of 2 entities: apples and the player.
# rather than use components, keep things simple and just encode location directly

abstract type Entity end

mutable struct Player <: Entity 
    x::Int
    y::Int
end

mutable struct Apple <: Entity 
    x::Int
    y::Int
end

# when we move an entity, they follow some rules. 
# all entities must stay within the game board, and apples must not move
# on top of other entities. the player can move on top of apples to eat them,
# at which point that apple should be deleted.
function update!(game, e::Apple, move::MoveAction)
    # obviously, collision is a complicated topic that without a doubt 
    # typically requires special data structures to make detection efficient
    # when dealing with lots of objects in a scene that interact, but here
    # our game is much simpler so we will just ignore all that

    # get the proposed new location, then check for collisions
    new_x, new_y = do_move(game, e, move)
    for entity in values(game.entities)
        if e != entity && new_x == entity.x && new_y == entity.y
            # we would collide, so ignore this move.
            @debug "Ignoring $move for Entity $e due to collision with $entity"
            return
        end
    end
    e.x = new_x
    e.y = new_y
    @debug "Moving $e to $new_x, $new_y"
    return
end

function do_move(game, entity, move)

    x, y = entity.x, entity.y

    if move.direction == DIR_UP
        y = max(1, y - 1)
    elseif move.direction == DIR_DOWN
        y = min(game.height, y + 1)
    elseif move.direction == DIR_LEFT
        x = max(1, x - 1)
    elseif move.direction == DIR_RIGHT
        x = min(game.width, x + 1)
    end

    return x, y
end