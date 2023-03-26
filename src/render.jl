
# helper functions for the window size for each app state
get_state_window_size(::AppState) = (640, 640)
get_state_window_size(state::PlayState) = (ncols(state.game) * 32, nrows(state.game) * 32)

function get_renderer_size(renderer::Ptr{SDL_Renderer})::Tuple{Int, Int}
    # get renderer height, weidth
    renderer_h_ref = Ref{Int32}()
    renderer_w_ref = Ref{Int32}()
    @sdl_assert () -> SDL_GetRendererOutputSize(renderer, renderer_w_ref, renderer_h_ref) res -> res == 0
    return renderer_w_ref[], renderer_h_ref[]
end

function render(renderer, state::AppState)

    # draw one frame, dispatch on state for specific rendering

    # clear canvas to background color.
    SDL_SetRenderDrawColor(renderer, 25, 25, 25, 200) # dark grey
    SDL_RenderClear(renderer)

    # draw update
    _render(renderer, state)

    SDL_RenderPresent(renderer)
    return
end

_render(_, state) = @debug "Render called on $state"

function _render(renderer, ::MainMenuState)

    # check if main menu textures have been created, else create them
    if !("title_text" in keys(textures))
        # create textures and add to global textures
        font_24 = get_font(font_mgr["liberation"], 24)
        color = SDL_Color(255, 255, 255, 255)
        textures["title_text"] = TextDrawable(renderer, font_24, color, "Minesweeper")
        font_16 = get_font(font_mgr["liberation"], 16)
        textures["menu_easy"] = TextDrawable(renderer, font_16, color, "easy")
        textures["menu_intermediate"] = TextDrawable(renderer, font_16, color, "intermediate")
        textures["menu_hard"] = TextDrawable(renderer, font_16, color, "expert")
    end

    minesweeper_text = textures["title_text"]
    easy_text = textures["menu_easy"]
    int_text = textures["menu_intermediate"]
    hard_text = textures["menu_hard"]

    WIN_WIDTH, WIN_HEIGHT = get_renderer_size(renderer)
    # RENDER TEXTS

    # center them all horizontally
    title_x = (WIN_WIDTH - width(minesweeper_text)) ÷ 2
    easy_x = (WIN_WIDTH - width(easy_text)) ÷ 2
    int_x = (WIN_WIDTH - width(int_text)) ÷ 2
    hard_x = (WIN_WIDTH - width(hard_text)) ÷ 2

    # get height; title at top
    title_y = 0
    easy_y = WIN_HEIGHT ÷ 3
    int_y = (WIN_HEIGHT ÷ 3) + (WIN_HEIGHT ÷ 9)
    hard_y = (WIN_HEIGHT ÷ 3) + 2*(WIN_HEIGHT ÷ 9)

    title_dest_ref = Ref(SDL_Rect(title_x, title_y, width(minesweeper_text), height(minesweeper_text)))
    easy_dest_ref = Ref(SDL_Rect(easy_x, easy_y, width(easy_text), height(easy_text)))
    int_dest_ref = Ref(SDL_Rect(int_x, int_y, width(int_text), height(int_text)))
    hard_dest_ref = Ref(SDL_Rect(hard_x, hard_y, width(hard_text), height(hard_text)))
    SDL_RenderCopy(renderer, minesweeper_text.texture, C_NULL, title_dest_ref)
    SDL_RenderCopy(renderer, easy_text.texture, C_NULL, easy_dest_ref)
    SDL_RenderCopy(renderer, int_text.texture, C_NULL, int_dest_ref)
    SDL_RenderCopy(renderer, hard_text.texture, C_NULL, hard_dest_ref)
    return

end


function _render(renderer, state::PlayState)
    # render a game in progress. 
    # we render this as a grid, using colored squares to indicate the following:
    # grey for unopened
    # white with black text for opened (TODO)
    # red for flagged
    # black for mine.
    
    # CREATE textures for hints here
    if !("hints_0" in keys(textures))
        font_12 = get_font(font_mgr["liberation"], 12)
        color = SDL_Color(10, 10, 10, 255)
        for i in 0:8
            textures["hint_$i"] = TextDrawable(renderer, font_12, color, "$i")
        end
    end

    WIN_WIDTH, WIN_HEIGHT = get_renderer_size(renderer)

    PAD = 2 # pixels
    out_height = WIN_HEIGHT / nrows(state.game)
    out_width = WIN_WIDTH / ncols(state.game)
    in_height = out_height - PAD
    in_width = out_width - PAD

    for row in 1:nrows(state.game)
        for col in 1:ncols(state.game)
            # set draw color based on the cell location
            SDL_SetRenderDrawColor(renderer, get_cell_draw_color(state.game, row, col)...)
            # draw a rectangle at each grid position
            rect = Ref(SDL_FRect((col-1) * out_width + PAD, (row-1) * out_height + PAD, in_width, in_height))
            SDL_RenderDrawRectF(renderer, rect)
            SDL_RenderFillRectF(renderer, rect)

            # now we render textures for hints (eventually also flags and mines)
            if state.game.states[row, col] == opened && !state.game.mines[row, col] # opened and not mine
                # HINT
                hint_count = state.game.hints[row, col]
                hint_text = textures["hint_$hint_count"]
                # we can't render textures using FRect, so convert these to ints.
                # use double padding so it's centered in the cell
                hint_x, hint_y = round(Int, (col-1) * out_width + 2*PAD), round(Int, (row-1) * out_height + 2*PAD)
                hint_w, hint_h = round(Int, in_width-PAD), round(Int, in_height-PAD) # subtract PAD again so it's effectively - 2*PAD
                hint_dest_ref = Ref(SDL_Rect(hint_x, hint_y, hint_w, hint_h))
                SDL_RenderCopy(renderer, hint_text.texture, C_NULL, hint_dest_ref)
            end
                
        end
    end

end

function get_cell_draw_color(game::MinesweeperGame, row, col)
    
    # choose the render color based on the cell state:
    # unopened grey, flagged red, black mine, white opened.
    if game.states[row, col] == unopened
        return (100, 100, 100, 255) # grey
    elseif game.states[row, col] == flagged
        return (240, 10, 30, 255) # red
    end
    # location is opened.
    if game.mines[row, col] # location has mine
        return (5, 5, 5, 255) # black
    end
    return (240, 240, 240, 255) # white for opened
end