# simple "game loop" handling input, demonstrating game state machine 
# This example renders the "gameplay" of the board states, and menu
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

## RENDERING FUNCTIONS

render(::QuitState, _) = return

function render(state::GameState, renderer) 
    # perform rendering, including dispatching on gameplay state. also do setup, cleanup tasks.

    # clear the canvas of our backbuffer
    SDL_RenderClear(renderer)
    # draw 
    _render(state, renderer)
    # All SDL drawing functions render to a "backbuffer"; they will not be shown until SDL_RenderPresent is called, at which point the buffer is invalidated
    # and all changes are drawn to the screen.
    SDL_RenderPresent(renderer)

end

function _render(::MenuState, renderer)
    # render the main menu state

    # if we haven't created the texture for our text yet, do that here
    if !("menu_text" in keys(textures))
        # create text surface, then texture, caching in dictionary
        color = SDL_Color(255, 255, 255, 255)

        surf_msg = TTF_RenderUTF8_Solid(ttf_font_ref[], "Press Enter to Play, Escape to Quit.", color)
        texture_msg = SDL_CreateTextureFromSurface(renderer, surf_msg)
        textures["menu_text"] = (surf_msg, texture_msg)
    end

    surf_msg, texture_msg = textures["menu_text"]
    # we dereference the SDL_Surface obj here so we can access its fields:
    surf_msg_jl = unsafe_load(surf_msg)
    # now we render the texture message
    text_x, text_y = (WIN_WIDTH - surf_msg_jl.w) ÷ 2, (WIN_HEIGHT - surf_msg_jl.h) ÷ 2
    dest_ref = Ref(SDL_Rect(text_x, text_y, surf_msg_jl.w, surf_msg_jl.h))
    SDL_RenderCopy(renderer, texture_msg, C_NULL, dest_ref)

end

function _render(state::PlayState, renderer)
    # render the gameplay state
    return
end


    
## MAIN PROGRAM
const WIN_WIDTH, WIN_HEIGHT = 640, 820
const ttf_font_ref = Ref{Ptr{TTF_Font}}()
# textures contains created textures used for rendering throughout the program; these all must be destroyed before program exit
const textures = Dict{String, Tuple{Ptr{SDL_Surface}, Ptr{SDL_Texture}}}()

function main()

    
    # INITIALIZE SDL
    @assert SDL_Init(SDL_INIT_EVERYTHING) == 0 "error initializing SDL: $(unsafe_string(SDL_GetError()))"
    # Initialize TTF for text rendering
    @assert TTF_Init() == 0 "error initializing TTF: $(unsafe_string(SDL_GetError()))"
    @assert (ttf_font_ref[] = TTF_OpenFont("ex/Conquest.ttf", 32)) != C_NULL "error loading TTF Font: $(unsafe_string(SDL_GetError()))"

    @assert (win = SDL_CreateWindow("Menu", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WIN_WIDTH, WIN_HEIGHT, SDL_WINDOW_SHOWN)) != C_NULL "error creating SDL window: $(unsafe_string(SDL_GetError()))"
    # create renderer for drawing to the window
    @assert (renderer = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)) != C_NULL "error creating SDL renderer: $(unsafe_string(SDL_GetError()))"
    try
        # setup rendering details
        SDL_SetRenderDrawColor(renderer, 25, 25, 25, 200) # dark grey

        gamestate = MenuState()

        transition_state(nothing, gamestate)
        while !(gamestate isa QuitState)

            # handle inputs 
            newstate = handle_input(gamestate)

            # update game 
            transition_state(gamestate, newstate)
            gamestate = newstate

            # render game
            render(gamestate, renderer)

            # delay, effectively 60FPS
            SDL_Delay(1000 ÷ 60)
            
        end
    
    finally
        # destroy all textures
        for (surf, tex) in values(textures)
            SDL_DestroyTexture(tex)
            SDL_FreeSurface(surf)
        end
        # DESTROY SDL
        TTF_CloseFont(ttf_font_ref[])
        TTF_Quit()
        SDL_DestroyRenderer(renderer)
        SDL_DestroyWindow(win)
        SDL_Quit()
    end
end

main()