

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



function start_game()

    # INITIALIZE SDL
    @sdl_assert () -> SDL_Init(SDL_INIT_EVERYTHING) res -> res == 0
    # Initialize TTF for text rendering
    call_SDL(() -> TTF_Init(), res -> res == 0)
    # load ttf font
    font_mgr["liberation"] = FontManager(joinpath([@__DIR__, "../ex/Liberation.ttf"]))
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

        # SDL TEARDOWN
        empty!(textures)
        empty!(font_mgr)
        # force garbage collection here so the finalizers for textures, fonts
        # run before we quit TTF and SDL.
        GC.gc()
        TTF_Quit()
        SDL_DestroyRenderer(renderer)
        SDL_DestroyWindow(win)
        SDL_Quit()
    end
end