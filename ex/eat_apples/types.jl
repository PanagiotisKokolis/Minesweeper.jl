
# -- ENTITIES TYPES

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
    patience::Int
end

# -- GAME ACTIONS TYPES

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

struct DeleteAction <: GameAction end

# -- GAME TYPES

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

# -- ENGINE / APPLICATION TYPES

# states for the game engine itself. I'm actually not sure if this is how I should
# represent and think about this.
abstract type EngineState end

abstract type MenuState <: EngineState end
struct MainMenuState <: MenuState end
struct PauseMenuState <: MenuState
    game::EatingApplesGame
end
struct PlayState <: EngineState 
    game::EatingApplesGame
end
struct QuitState <: EngineState end