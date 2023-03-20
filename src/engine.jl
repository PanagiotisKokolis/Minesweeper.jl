

# overview of game engine responsibilities

# while not exiting:
#   1. handle user input
#   2. update game state
#   3. render game state

abstract type AppState end

struct MainMenuState <: AppState end

struct ResultState <: AppState end
struct PlayState <: AppState 
    game::MinesweeperGame
end
struct QuitState <: AppState end

function handle_input end

function handle_input(state::AppState)

    event_ref = Ref{SDL_Event}()
    
    while Bool(SDL_PollEvent(event_ref))
        event = event_ref[]
        type = SDL_EventType(event.type) # cast the Uint to an SDL_EventType
        # handle inputs (mostly mouse, but some keyboard events like ESC)
        # we want to change behavior based on app state.
        # @debug "Processing event for $type"
        result = handle_input(state, Val(type), event)

        if !isnothing(result)
            return result
        end 
    end
    # if we haven't returned a new state to transition to, return the current state 
    return state
end

handle_input(state, type, event) = nothing
handle_input(state, event, type, key) = nothing

# quit from anywhere whenever we receive a QUIT event
handle_input(::AppState, ::Val{SDL_QUIT}, _) = QuitState()

# handle keyboard events - we need to pull out the scancode of the button to dispatch
function handle_input(state::AppState, type::Val{SDL_KEYDOWN}, event)
    scancode = event.key.keysym.scancode
    # dispatch on state, SDL_KeyboardEvent, SDL_KEYDOWN, which key (scancode)
    return handle_input(state, event.key, type, Val(scancode))
end

handle_input(::MainMenuState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_ESCAPE}) = QuitState()
# quit game while playing with escape
handle_input(::PlayState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_ESCAPE}) = MainMenuState()

# handle mouse button events
function handle_input(state::AppState, type::Val{SDL_MOUSEBUTTONDOWN}, event)
    @debug "Handling mouse button down event."
    button_event = event.button
    button_code = convert(Int, event.button.button) # cast to integer, because the SDL_BUTTON defs are Int64
    # dispatch on state, SDL_MouseButtonEvent, SDL_MOUSEBUTTONDOWN, which mouse button
    return handle_input(state, button_event, type, Val(button_code))
end

# left clicking in main menu should check if a new game will be created based on the clicked
# difficulty, otherwise do nothing. If a new game is created, then change state to PlayState
function handle_input(state::MainMenuState, event::SDL_MouseButtonEvent, ::Val{SDL_MOUSEBUTTONDOWN}, ::Val{SDL_BUTTON_LEFT}) 
    @debug "Left click on MainMenuState"
    # get mouse click position
    mouse_x, mouse_y = event.x, event.y
    # check if difficulty clicked
    difficulty = select_difficulty(mouse_x, mouse_y, WIN_WIDTH, WIN_HEIGHT)
    # change state accordingly
    if !isnothing(difficulty)
        @debug "Creating new game $difficulty"
        # create a new game,a nd return a PlayState with that new game
        return PlayState(create_game(difficulty))
    end
    return state
end

function select_difficulty(x, y, width, height)
    #get the click function
    # easy 0 +(width/3) < easy < width - (width/3)
    # easy (height/3) + (height/9)  < easy < height - (2)(height/9)
    #determined if it clicked something
    if (width/3) < x < width - (width/3)
        if height/3 < y < (height/3) +(height/9)
            return :easy
        elseif  (height/3)+(height/9) < y < (height/3) + 2(height/9)
            return :intermediate 
        elseif (height/3) + 2*(height/9)< y < height - (height/3)
            return :expert
        end
    end
    return nothing
end



function start_game()

    # INITIALIZE SDL
    call_SDL(() -> SDL_Init(SDL_INIT_EVERYTHING), res -> res == 0)
    # Initialize TTF for text rendering
    call_SDL(() -> TTF_Init(), res -> res == 0)
    # load ttf font
    ttf_font_ref[] = call_SDL(() -> TTF_OpenFont(joinpath([@__DIR__, "../ex/Liberation.ttf"]), 16), res -> res != C_NULL)
    # create window and renderer
    win = call_SDL(() -> SDL_CreateWindow("Minesweeper", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WIN_WIDTH, WIN_HEIGHT, SDL_WINDOW_SHOWN), res -> res != C_NULL)
    renderer = call_SDL(() -> SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC), res -> res != C_NULL)
    try
        eng_state = MainMenuState()

        while !(eng_state isa QuitState)


            eng_state = handle_input(eng_state)

            render(renderer, eng_state)

            SDL_Delay(1000 ÷ 60)
        end
    finally
        # free all surfaces, textures
        for (surf, txtr) in values(textures)
            SDL_DestroyTexture(txtr)
            SDL_FreeSurface(surf)
        end

        # SDL TEARDOWN
        TTF_CloseFont(ttf_font_ref[])
        TTF_Quit()
        SDL_DestroyRenderer(renderer)
        SDL_DestroyWindow(win)
        SDL_Quit()
    end
end