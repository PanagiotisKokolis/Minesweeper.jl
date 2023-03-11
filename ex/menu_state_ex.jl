# simple "game loop" handling input, demonstrating game state machine 
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2

# we have two game states: menu, and "play". 
# In the menu, the user is prompted to play (Enter) or to exit (Escape). 
# In "Play", the user presses wasd or arrow keys to move between UP, LEFT, CENTER, DOWN, RIGHT states, and can press Escape to return to Menu.


"""
BoardState{N} is a parametric type representing the state of the board. 
It is parameterized by symbols - :UP, :LEFT, :RIGHT, :DOWN, :CENTER representing
where a player is on the board.
"""
struct BoardState{N} end

"""
GameState represents the global state of the game, either MenuState or PlayState or QuitState concretely.
"""
abstract type GameState end

struct MenuState <: GameState end
struct QuitState <: GameState end

mutable struct PlayState <: GameState 
    boardstate::BoardState{N} where N
end
function PlayState()
    return PlayState(BoardState{:CENTER}())
end


"""
For each game state, handle inputs differently. This is effectively a transition function from one state to another.
"""
function handle_input(state::GameState)::GameState
    println("handle_input fallback; maybe error? $state")
    return state
end

"""
    handle_input(::MenuState)
Handle the main menu inputs.
"""
function handle_input(state::MenuState)

    event_ref = Ref{SDL_Event}()

    while Bool(SDL_PollEvent(event_ref))
        # work thru event queue until a handled event is encountered; this might not be necessary, honestly
        event = event_ref[]

        if event.type == SDL_QUIT || event.type == SDL_KEYDOWN && event.key.keysym.scancode == SDL_SCANCODE_ESCAPE
            println("Exiting from MenuState")
            return QuitState()
        elseif event.type == SDL_KEYDOWN && event.key.keysym.scancode == SDL_SCANCODE_RETURN
            println("Enter pressed at MenuState")
            return PlayState()
        end
    end

    return state

end

function handle_input(state::PlayState)

    event_ref = Ref{SDL_Event}()

    while Bool(SDL_PollEvent(event_ref))
        event = event_ref[]

        if event.type == SDL_QUIT
            println("Exiting from PlayState")
            return QuitState()
        elseif event.type == SDL_KEYDOWN
            # return to main menu on Escape
            if event.key.keysym.scancode == SDL_SCANCODE_ESCAPE
                println("Returning to MenuState from PlayState")
                return MenuState()
            elseif event.key.keysym.scancode in (SDL_SCANCODE_W, SDL_SCANCODE_UP)
                # "up" key pressed
                return update_boardstate!(state, Val(:up))
            elseif event.key.keysym.scancode in (SDL_SCANCODE_A, SDL_SCANCODE_LEFT)
                # "left" key pressed
                return update_boardstate!(state, Val(:left))
            elseif event.key.keysym.scancode in (SDL_SCANCODE_S, SDL_SCANCODE_DOWN)
                # "down" key pressed
                return update_boardstate!(state, Val(:down))
            elseif event.key.keysym.scancode in (SDL_SCANCODE_D, SDL_SCANCODE_RIGHT)
                # "right" key pressed
                return update_boardstate!(state, Val(:right))
            end
        end
    end

    return state
end

"""
    update_boardstate!(PlayState, Val)

Update the state of play as a transition function f(current_state, input) -> new_state which modifies its input state
"""
function update_boardstate! end

function update_boardstate!(state::PlayState, ::Val{:up})
    # when UP is pressed, either move from DOWN -> CENTER or CENTER -> UP, else nothing.

    if state.boardstate isa BoardState{:DOWN}
        state.boardstate = BoardState{:CENTER}()
        println("Moved from BOTTOM to CENTER.")
    elseif state.boardstate isa BoardState{:CENTER}
        state.boardstate = BoardState{:UP}()
        println("Moved from CENTER to UP.")
    end
    return state
end

function update_boardstate!(state::PlayState, ::Val{:left})
    # when LEFT is pressed, move from RIGHT to CENTER or CENTER to LEFT, else nothing
    if state.boardstate isa BoardState{:RIGHT}
        state.boardstate = BoardState{:CENTER}()
        println("Moved from RIGHT to CENTER.")
    elseif state.boardstate isa BoardState{:CENTER}
        state.boardstate = BoardState{:LEFT}()
        println("Moved from CENTER to LEFT.")
    end
    return state
end

function update_boardstate!(state::PlayState, ::Val{:right})

    if state.boardstate isa BoardState{:LEFT}
        state.boardstate = BoardState{:CENTER}()
        println("Moved from LEFT to CENTER.")
    elseif state.boardstate isa BoardState{:CENTER}
        state.boardstate = BoardState{:RIGHT}()
        println("Moved from CENTER to RIGHT.")
    end
    return state
end

function update_boardstate!(state::PlayState, ::Val{:down})
    if state.boardstate isa BoardState{:UP}
        state.boardstate = BoardState{:CENTER}()
        println("Moved from UP to CENTER.")
    elseif state.boardstate isa BoardState{:CENTER}
        state.boardstate = BoardState{:DOWN}()
        println("Moved from CENTER to DOWN.")
    end
    return state
end

# do nothing if the state we're leaving and the state we're going to are the same
transition_state(::S, ::S) where {S <: GameState} = nothing

function transition_state(::Nothing, ::MenuState)
    # whenever you enter the menu state.
    println("You are in the main menu. Press Escape to quit or Enter to play.")
end

function transition_state(::MenuState, ::PlayState)
    # whenever you enter the Play state
    println("You are playing. Use WASD or arrow keys to move around. You are at CENTER.")
end

function transition_state(old::GameState, new::GameState)
    println("Exiting $old Entering $new")
end


    



function main()

    # INITIALIZE SDL
    SDL_Init(SDL_INIT_EVERYTHING)
    win = SDL_CreateWindow("Menu", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 640, 640, SDL_WINDOW_SHOWN)

    gamestate = MenuState()

    transition_state(nothing, gamestate)
    while !(gamestate isa QuitState)

        newstate = handle_input(gamestate)
        transition_state(gamestate, newstate)
        gamestate = newstate
        
    end
    

    # DESTROY SDL 
    SDL_DestroyWindow(win)
    SDL_Quit()

end

main()