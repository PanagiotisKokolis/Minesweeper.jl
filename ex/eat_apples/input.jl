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
# MOVEMENT
# There's an interesting coupling here: we're tying the keyboard input (in this state) both to a specific gameplay action 
# AND a specific actor. Good enough for now, but it's an area we could decouple.
# We also likely want to abstract 'push Action event to Game' out of here.
# Another consideration is how do we associate controllers with entity IDs (:PLAYER), and other related thigns.
# Also, this seems like a good place where macros would come in handy since a lot of this code repeats over variables;
# imagine a loop that takes pairs (SCANCODE, ACTION) and generates each line below.
handle_input(play::PlayState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_UP}) = (push!(play.game.actions, (:PLAYER, MoveAction(DIR_UP))); return play)
handle_input(play::PlayState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_LEFT}) = (push!(play.game.actions, (:PLAYER, MoveAction(DIR_LEFT))); return play)
handle_input(play::PlayState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_DOWN}) = (push!(play.game.actions, (:PLAYER, MoveAction(DIR_DOWN))); return play)
handle_input(play::PlayState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_RIGHT}) = (push!(play.game.actions, (:PLAYER, MoveAction(DIR_RIGHT))); return play)