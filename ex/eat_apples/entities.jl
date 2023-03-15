
# this game consists of 2 entities: applies and the player.

abstract type Entity end

struct Player <: Entity end

struct Apple <: Entity end

# there are also 