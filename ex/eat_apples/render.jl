

function render(renderer, state::EngineState)
    # do this every frame, then specialize on which state.

    # clear canvas to background color.
    SDL_SetRenderDrawColor(renderer, 25, 25, 25, 200) # dark grey
    SDL_RenderClear(renderer)
    # draw update 
    _render(renderer, state)
    # after we draw to the backbuffer, we need to copy that to the active buffer.
    SDL_RenderPresent(renderer)
    return
end


_render(_, ::QuitState) = @debug "Render called on QuitState"

# We need several render functions for each engine state. 
function _render(renderer, ::MainMenuState) 
    # render the main menu, which just displays some text in the center of the screen
    # with the available actions.
    # Here, I'm checking if the textures I need have been created already and otherwise
    # creating them. I think managing assets should be extracted out of these functions 
    # and loaded/unloaded/freed at startup/shutdown. Unsure on exact pattern for this.
    # Could be a Renderable component which encapsulates the texture, sprite, etc...

    if !("main_menu_welcome" in keys(textures))
        # create texture and add to global textures...
        color = SDL_Color(255, 255, 255, 255)
        welcome_surf = TTF_RenderUTF8_Solid(ttf_font_ref[], "Welcome to Eating Apples!", color)
        welcome_txtr = SDL_CreateTextureFromSurface(renderer, welcome_surf)
        textures["main_menu_welcome"] = (welcome_surf, welcome_txtr)

        help_surf = TTF_RenderUTF8_Solid(ttf_font_ref[], "Press Enter to Play, Escape to Quit.", color)
        help_txtr = SDL_CreateTextureFromSurface(renderer, help_surf)
        textures["main_menu_help"] = (help_surf, help_txtr)
    end

    welcome_surf, welcome_txtr = textures["main_menu_welcome"]
    help_surf, help_txtr = textures["main_menu_help"]
    # dereference SDL_Surface obj to access its fields
    welcome_surf_jl, help_surf_jl = unsafe_load(welcome_surf), unsafe_load(help_surf)
    # render the text messages
    # center horizontally
    welcome_x = (WIN_WIDTH - welcome_surf_jl.w) ÷ 2
    help_x = (WIN_WIDTH - help_surf_jl.w) ÷ 2
    # center vertically
    welcome_y = (WIN_HEIGHT - (welcome_surf_jl.h + help_surf_jl.h)) ÷ 2
    help_y = (WIN_HEIGHT - (welcome_surf_jl.h + help_surf_jl.h)) ÷ 2 + welcome_surf_jl.h
    welcome_dest_ref = Ref(SDL_Rect(welcome_x, welcome_y, welcome_surf_jl.w, welcome_surf_jl.h))
    help_dest_ref = Ref(SDL_Rect(help_x, help_y, help_surf_jl.w, help_surf_jl.h))
    SDL_RenderCopy(renderer, welcome_txtr, C_NULL, welcome_dest_ref)
    SDL_RenderCopy(renderer, help_txtr, C_NULL, help_dest_ref)
    return
end


function _render(renderer, pause::PauseMenuState)
    # render the pause screen, which shows some text about available actions 
    # and the remaining apples.
    # "Game Paused. Press Escape to return to main menu or Enter to continue." 
    # "N apples remain"
    return
end

function _render(renderer, state::PlayState)
    # render the grid; we can make the grid dynamic based on the number of cells.

    # we want padding between the cells so we can see the grid.
    PADDING = 2 # pixels
    # calculate grid size in pixels
    outer_height = WIN_HEIGHT / state.game.height 
    outer_width = WIN_WIDTH / state.game.width
    inner_height = outer_height - PADDING
    inner_width = outer_width - PADDING

    # set render color to a beige 
    SDL_SetRenderDrawColor(renderer, 255, 220, 235, 200)
    for row in 1:state.game.height
        for col in 1:state.game.width
            # draw an empty rectangle at each grid position
            rect = Ref(SDL_FRect((col-1) * outer_width + PADDING, (row-1) * outer_height + PADDING, inner_width, inner_height))
            SDL_RenderDrawRectF(renderer, rect)
            SDL_RenderFillRectF(renderer, rect)
        end
    end

    # now draw the players and apples
    for (_, entity) in state.game.entities
        # draw a blue square.
        SDL_SetRenderDrawColor(renderer, get_entity_draw_color(entity)...)
        rect = Ref(SDL_FRect((entity.x-1) * outer_width + PADDING, (entity.y-1) * outer_height + PADDING, inner_width, inner_height))
        SDL_RenderDrawRectF(renderer, rect)
        SDL_RenderFillRectF(renderer, rect)
    end
    return
end

get_entity_draw_color(::Player) = (80, 160, 250, 255)
get_entity_draw_color(::Apple) = (255, 0, 0, 255)