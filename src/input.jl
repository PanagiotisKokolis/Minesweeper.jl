

function handle_input end

"""
    handle_input(state::AppState) -> AppState

Handle input events and return a new AppState to transition to.
"""
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
# quit to main menu while playing with escape
handle_input(::PlayState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_ESCAPE}) = MainMenuState()

# handle mouse button events
function handle_input(state::AppState, type::Val{SDL_MOUSEBUTTONDOWN}, event)
    @debug "Handling mouse button down event."
    button_event = event.button
    button_code = convert(Int, event.button.button) # cast to integer, because the SDL_BUTTON defs are Int64
    # dispatch on state, SDL_MouseButtonEvent, SDL_MOUSEBUTTONDOWN, which mouse button
    return handle_input(state, button_event, type, Val(button_code))
end

"""
    handle_input(state::MainMenuState, event::SDL_MouseButtonEvent, ::Val{SDL_MOUSEBUTTONDOWN}, ::Val{SDL_BUTTON_LEFT}) -> AppState

Handle a left click on the main menu. If a difficulty is selected, then create a new game and return a PlayState with that game.
"""
function handle_input(state::MainMenuState, event::SDL_MouseButtonEvent, ::Val{SDL_MOUSEBUTTONDOWN}, ::Val{SDL_BUTTON_LEFT}) 
    @debug "Left click on MainMenuState"
    WIN_WIDTH, WIN_HEIGHT = get_state_window_size(state)
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

function handle_input(state::PlayState, event::SDL_MouseButtonEvent, ::Val{SDL_MOUSEBUTTONDOWN}, ::Val{SDL_BUTTON_LEFT})
    #maybe make this part into a function to be called
    selected_row , selected_col  = selected_cell(state, event)
    if reveal(state.game, selected_row, selected_col) == -1
        @debug "clicked on a mine!"
        # is_game_over(state.game)
    end
    return state
end

function  handle_input(state::PlayState, event::SDL_MouseButtonEvent, ::Val{SDL_MOUSEBUTTONDOWN}, ::Val{SDL_BUTTON_RIGHT})
    selected_row , selected_col  = selected_cell(state, event)
    if state.game.states[selected_row, selected_col] == unopened
        state.game.states[selected_row, selected_col] = flagged
    elseif state.game.states[selected_row, selected_col] == flagged
        state.game.states[selected_row, selected_col] = unopened
    end
    return state
end

function selected_cell(state::PlayState, event::SDL_MouseButtonEvent)
    WIN_WIDTH, WIN_HEIGHT = get_state_window_size(state)
    row_size = WIN_HEIGHT ÷ nrows(state.game)
    col_size = WIN_WIDTH ÷ ncols(state.game)
    mouse_x, mouse_y = event.x, event.y
    selected_row =  (mouse_y ÷ row_size) + 1
    selected_col =  (mouse_x ÷ col_size) + 1
    return selected_row , selected_col
end

"""
    select_difficulty(x, y, width, height) -> Union{Symbol, Nothing}

Determine if a click at (x, y) is within the bounds of a difficulty button. 
If so, return the difficulty symbol (:easy, :intermediate, :expert). Otherwise, return nothing.
"""
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