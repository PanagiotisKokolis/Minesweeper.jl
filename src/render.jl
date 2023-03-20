
function render(renderer, state::AppState)

    # draw one frame, dispatch on state for specific rendering

    # clear canvas to background color.
    SDL_SetRenderDrawColor(renderer, 25, 25, 25, 200) # dark grey
    SDL_RenderClear(renderer)

    # draw update
    render(renderer, state)

    SDL_RenderPresent(renderer)
    return
end

render(_, ::QuitState) = @debug "Render called on QuitState"

function render(renderer, ::MainMenuState)

    