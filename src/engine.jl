

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

"""
    GameEngine

A mutable struct to represent the running game engine.
This will handle SDL initialization and teardown, contain the
game state, and any other engine-wide variables.
"""
mutable struct GameEngine
    # SDL variables
    sdl_initialized::Bool
    ttf_initialized::Bool
    window::Ptr{SDL_Window}
    renderer::Ptr{SDL_Renderer}
    # game state
    state::AppState
    # inner constructor that attaches the finalizer
    function GameEngine()
        obj = new(false, false, C_NULL, C_NULL, MainMenuState())
        finalizer(obj) do self
            @async @debug "Destroying GameEngine $self; destroying SDL and TTF."
            shutdown!(self)
        end
    end
end

function startup!(eng::GameEngine)
    # initialize SDL
    @sdl_assert () -> SDL_Init(SDL_INIT_EVERYTHING) res -> res == 0
    eng.sdl_initialized = true
    # initialize TTF
    @sdl_assert () -> TTF_Init() res -> res == 0
    eng.ttf_initialized = true
    # create window and renderer
    eng.window = @sdl_assert () -> SDL_CreateWindow("Minesweeper", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WIN_WIDTH, WIN_HEIGHT, SDL_WINDOW_SHOWN) res -> res != C_NULL
    eng.renderer = @sdl_assert () -> SDL_CreateRenderer(eng.window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC) res -> res != C_NULL
    return
end

function shutdown!(eng::GameEngine)
    # destroy renderer and window
    SDL_DestroyRenderer(eng.renderer)
    eng.renderer = C_NULL
    SDL_DestroyWindow(eng.window)
    eng.window = C_NULL
    # teardown TTF
    if eng.ttf_initialized
        TTF_Quit()
        eng.ttf_initialized = false
    end
    # teardown SDL
    if eng.sdl_initialized
        SDL_Quit()
        eng.sdl_initialized = false
    end
    return
end


function start_game()

    # INITIALIZE Game Engine
    eng = GameEngine()
    startup!(eng)
    # load ttf font
    font_mgr["liberation"] = FontManager(joinpath([@__DIR__, "../ex/Liberation.ttf"]))
    try
        while !(eng.state isa QuitState)

            eng.state = handle_input(eng.state)

            render(eng.renderer, eng.state)

            SDL_Delay(1000 ÷ 60)
        end
    finally

        # SDL TEARDOWN
        empty!(textures)
        empty!(font_mgr)
        # force garbage collection here so the finalizers for textures, fonts
        # run before we quit TTF and SDL.
        GC.gc()
        # shutdown engine; this is also called in the finalizer...
        shutdown!(eng)
    end
end