# handle input

# we have several engine states that modify how inputs are handled.
# MainMenuState and PauseMenuState are identical <: MenuState,
# and the real interesting state is GameState. Here, the inputs 
# need to be mapped to gameplay Actions that can be used during the
# update() step. 

# one way to think about these Actions is that they are inputs to 
# the entities' components state machines. As in, if update(char, JUMP()) is the 
# action for a given update, the update step will input that to the character's 
# state machine (which could actually be something more complicated lika a PDA)
# and transition them accordingly. 

# DESIGN NOTE: I am going to use multiple dispatch based on the value of the SDL_EventType
# read from the event queue. This is just a test to feel how ergonomic it is, and I'm also
# unsure of the performance, although it seems unlikely to be much worse than if-else 
# statements ?
"""
    handle_input

Based on the state of the game, handle inputs.
"""
function handle_input(state::EngineState)

    event_ref = Ref{SDL_Event}()

    while Bool(SDL_PollEvent(event_ref))

        event = event_ref[]
        type = SDL_EventType(event.type) # We cast this UInt16 to an SDLEventType so we can dispatch
        result = handle_input(state, Val(type), event)
        if !isnothing(result)
            # only return if we popped off an event we have a method to handle.
            return result
        end
    end
    # if we've processed all events and none were handled, return the current state
    return state
end

# fallback for handle_input; essentially these mean "ignore this input event"
handle_input(state, val, event) = nothing
handle_input(state, event, event_type, key) = nothing

# handle QUIT events
handle_input(::EngineState, ::Val{SDL_QUIT}, _) = QuitState()

# handle KEYDOWN events
# first, we dispatch on the union typedef so we can dispatch on the actual key pressed
function handle_input(state::EngineState, k::Val{SDL_KEYDOWN}, event)
    scancode = event.key.keysym.scancode
    return handle_input(state, event.key, k, Val(scancode))
end

# MENU input handling ############

# when ESCAPE is pressed at the main menu state, exit the game.
handle_input(::MainMenuState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_ESCAPE}) = QuitState()
# when ENTER is pressed in main menu state, start game 
handle_input(::MainMenuState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_RETURN}) = PlayState(EatingApplesGame())
# when ESCAPE is pressed at pause menu, return to main menu
handle_input(::PauseMenuState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_ESCAPE}) = MainMenuState()
# resume game with ENTER at pause state
handle_input(pause::PauseMenuState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_RETURN}) = PlayState(pause.game)

# GAME input handling ############
# ESCAPE to PAUSE
handle_input(play::PlayState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_ESCAPE}) = PauseMenuState(play.game)
# TODO: parse gameplay inputs