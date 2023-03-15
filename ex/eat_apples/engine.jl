# game engine for Eating Apples.

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

# STATE TRANSITION helper function, doesn't do much for now.
# do nothing if the state we're leaving and the state we're going to are the same
transition_state(::S, ::S) where {S <: EngineState} = nothing

function transition_state(::Union{Nothing, PauseMenuState}, ::MainMenuState)
    # whenever you enter the menu state.
    println("You are in the main menu. Press Escape to quit or Enter to play.")
end

function transition_state(::MenuState, ::PlayState)
    # whenever you enter the Play state
    println("You are playing. Use WASD or arrow keys to move around.")
end

transition_state(::PlayState, ::PauseMenuState) = println("You have paused the game.")

function transition_state(old::EngineState, new::EngineState)
    println("Exiting $old Entering $new")
end


# normally I hate globals, but I made the decision that this entire codeset represents
# a single instance of a running game, so rather than put these things in a Game struct
# and pass that around, I made them global. Probably I won't do this in the future.

const WIN_WIDTH, WIN_HEIGHT = 820, 640
const ttf_font_ref = Ref{Ptr{TTF_Font}}()


function start_game()

    # INITIALIZE SDL 
    # SDL can be thought of as a game engine "backend", which provides utilities
    # for handling input, rendering, etc...
    # In that sense, it logically falls under part of the game "engine" rather than 
    # being restricted solely to rendering. 

    # SDL for game utilities, rendering
    call_SDL(() -> SDL_Init(SDL_INIT_EVERYTHING), res -> res == 0)
    # TTF for text rendering
    call_SDL(() -> TTF_Init(), res -> res == 0)
    # load font.
    ttf_font_ref[] = call_SDL(() -> TTF_OpenFont(joinpath([@__DIR__, "../Liberation.ttf"]), 16), res -> res != C_NULL)
    # create SDL window and renderer
    win = call_SDL(() -> SDL_CreateWindow("Menu", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WIN_WIDTH, WIN_HEIGHT, SDL_WINDOW_SHOWN), res -> res != C_NULL)
    renderer = renderer = call_SDL(() -> SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC), res -> res != C_NULL)

    # game loop
    try
        # initialize game engine state.
        eng_state = MainMenuState()

        while !(eng_state isa QuitState) 

            # handle inputs
            # we want to abstract the input device from the actual actions performed.
            # we also want to distinguish between inputs that modify the engine state 
            # e.g. pause the game, navigate a menu
            # and inputs that create gameplay actions /while/ playing (e.g. ↑ MOVE_UP)
            # ONE way to help decouple all this is to imagine networked games. the game
            # engine has an update loop that reacts to actions created by players, AI, 
            # etc. All of this continues to run even if a given player has tabbed, or 
            # opens a menu. Clearly there are at least two different systems: one handling
            # action events in the game itself, and one handling inputs coming from a
            # user and their input device.
            new_state = handle_input(eng_state)

            # Handling inputs can create transition events for the EngineState AND
            # create action events for gameplay. Transition EngineState first.
            transition_state(eng_state, new_state)
            eng_state = new_state
            
            # update game
            # this would include transition between menu states as well as updating 
            # the entities within the game. Here, I think those could be handled 
            # in the same location, however they really aren't the same procedure...
            # What separating these two things would allow us to do is to have 
            # game event actions continue to update the play state while the user
            # is in a different "engine" state, like in a menu.

            # render game

            # delay
            SDL_Delay(1000 ÷ 60)

        end
    finally
        # DESTROY SDL

        TTF_CloseFont(ttf_font_ref[])
        TTF_Quit()
        SDL_DestroyRenderer(renderer)
        SDL_DestroyWindow(win)
        SDL_Quit()
    end
end
