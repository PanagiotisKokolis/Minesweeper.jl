
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
        color = SDL_Color(255, 255, 255, 255)
        minesweeper_surf = TTF_RenderUTF8_Solid(ttf_font_ref[], "Minesweeper", color)
        minesweeper_txtr = SDL_CreateTextureFromSurface(renderer, minesweeper_surf)
        textures["title_text"] = (minesweeper_surf, minesweeper_txtr)

        easy_surf = TTF_RenderUTF8_Solid(ttf_font_ref[], "easy", color)
        easy_txtr = SDL_CreateTextureFromSurface(renderer, easy_surf)
        textures["menu_easy"] = (easy_surf, easy_txtr)

        int_surf = TTF_RenderUTF8_Solid(ttf_font_ref[], "intermediate", color)
        int_txtr = SDL_CreateTextureFromSurface(renderer, int_surf)
        textures["menu_intermediate"] = (int_surf, int_txtr)

        hard_surf = TTF_RenderUTF8_Solid(ttf_font_ref[], "expert", color)
        hard_txtr = SDL_CreateTextureFromSurface(renderer, hard_surf)
        textures["menu_hard"] = (hard_surf, hard_txtr)
    end

    minesweeper_surf, minesweeper_txtr = textures["title_text"]
    easy_surf, easy_txtr = textures["menu_easy"]
    int_surf, int_txtr = textures["menu_intermediate"]
    hard_surf, hard_txtr = textures["menu_hard"]

    # dereference SDL_Surface obj to access its fields
    minesweeper_surf_jl = unsafe_load(minesweeper_surf)
    easy_surf_jl = unsafe_load(easy_surf)
    int_surf_jl = unsafe_load(int_surf)
    hard_surf_jl = unsafe_load(hard_surf)

    # RENDER TEXTS

    # center them all horizontally
    title_x = (WIN_WIDTH - minesweeper_surf_jl.w) ÷ 2
    easy_x = (WIN_WIDTH - easy_surf_jl.w) ÷ 2
    int_x = (WIN_WIDTH - int_surf_jl.w) ÷ 2
    hard_x = (WIN_WIDTH - hard_surf_jl.w) ÷ 2

    # get height; title at top
    title_y = 0
    easy_y = WIN_HEIGHT ÷ 3
    int_y = (WIN_HEIGHT ÷ 3) + (WIN_HEIGHT ÷ 9)
    hard_y = (WIN_HEIGHT ÷ 3) + 2*(WIN_HEIGHT ÷ 9)

    title_dest_ref = Ref(SDL_Rect(title_x, title_y, minesweeper_surf_jl.w, minesweeper_surf_jl.h))
    easy_dest_ref = Ref(SDL_Rect(easy_x, easy_y, easy_surf_jl.w, easy_surf_jl.h))
    int_dest_ref = Ref(SDL_Rect(int_x, int_y, int_surf_jl.w, int_surf_jl.h))
    hard_dest_ref = Ref(SDL_Rect(hard_x, hard_y, hard_surf_jl.w, hard_surf_jl.h))
    SDL_RenderCopy(renderer, minesweeper_txtr, C_NULL, title_dest_ref)
    SDL_RenderCopy(renderer, easy_txtr, C_NULL, easy_dest_ref)
    SDL_RenderCopy(renderer, int_txtr, C_NULL, int_dest_ref)
    SDL_RenderCopy(renderer, hard_txtr, C_NULL, hard_dest_ref)
    return

end


function _render(renderer, state::PlayState)
    # render a game in progress. 
    # we render this as a grid, using colored squares to indicate the following:
    # grey for unopened
    # white with black text for opened (TODO)
    # red for flagged
    # black for mine.

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
        end
    end

end

get_cell_draw_color(game::MinesweeperGame, row, col) = (100, 100, 100, 255)