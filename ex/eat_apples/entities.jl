

# fallback for when we try an action on an entity that doesn't exist
function update!(_, ::Nothing, __)
    @debug "Called update! on entity Nothing"
    return
end

# when we move an entity, they follow some rules. 
# all entities must stay within the game board, and apples must not move
# on top of other entities. the player can move on top of apples to eat them,
# at which point that apple should be deleted.
function update!(game, entity::Apple, move::MoveAction)
    # obviously, collision is a complicated topic that without a doubt 
    # typically requires special data structures to make detection efficient
    # when dealing with lots of objects in a scene that interact, but here
    # our game is much simpler so we will just ignore all that

    # get the proposed new location, then check for collisions
    new_x, new_y = do_move(game, entity, move)
    collided_e_key = check_collision(game, entity, new_x, new_y)
    if !isnothing(collided_e_key)
        # apple collided with entity, so don't move.
        return
    end
    entity.x = new_x
    entity.y = new_y
    @debug "Moving $entity to $new_x, $new_y"
    return
end

function update!(game, player::Player, move::MoveAction)

    new_x, new_y = do_move(game, player, move)
    collided_e_key = check_collision(game, player, new_x, new_y)
    if !isnothing(collided_e_key)
        # mark this entity for deletion
        push!(game.actions, (collided_e_key, DeleteAction()))
    end
    player.x = new_x
    player.y = new_y
    @debug "Moving $player to $new_x, $new_y"
    return
end

function check_collision(game, entity, new_x, new_y)
    for (key, other_entity) in game.entities
        if entity != other_entity && new_x == other_entity.x && new_y == other_entity.y
            # we would collide, so ignore this move.
            @debug "Collision detected between $entity with $other_entity"
            return key
        end
    end
    return nothing
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

    @debug "Trying to move Entity $entity to ($x, $y)"

    return x, y
end