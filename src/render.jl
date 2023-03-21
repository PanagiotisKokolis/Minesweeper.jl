
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