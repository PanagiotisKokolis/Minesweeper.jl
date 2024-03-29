using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2

# These are OpenGL flags, undocumented in SDL_video.h 
SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 16)
SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 16)

# initialize all subsystems, e.g. SDL_INIT_VIDEO, SDL_INIT_AUDIO
@assert SDL_Init(SDL_INIT_EVERYTHING) == 0 "error initializing SDL: $(unsafe_string(SDL_GetError()))"
# SDL_GetError() returns the last error message created on the current thread; only check this message when you 
#     confirm an error has occurred (as above, where the return value of SDL_Init is checked)
# That is, if an error HASN'T occurred, the error message can still contain some value that will in that case
#     be irrelevant.

# window management is in SDL_video.h. 
# This is for creating windows but also managing their properties (resizing, max/minimized, handling events, etc)
# Create a window with the specified position, dimension, and flags. 
# parameters: SDL_CreateWindow(title::String, x_position::Int, y_position::Int, width::Int, height::Int, flags::Int)
# returns: the window that was created OR NULL on failure
win = SDL_CreateWindow("Game", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1000, 1000, SDL_WINDOW_SHOWN)
SDL_SetWindowResizable(win, SDL_TRUE)

# SDL_render.h handles 2D accelerated rendering: single pixels, pixel lines, filled rectangles, texture images
# Polygons, particle effects, 3D etc. are provided by other libraries (OpenGL) or 3D engines

# Create a 2D rendering context for the window. 
# parameters: SDL_CreateRenderer(window::SDL_Window, driver_index::Int, render_flags::Int)
# returns: SDL_Renderer or NULL on error
renderer = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)

# NOTE: SDL_Surface are used for CPU-side blit rendering; converting to Texture for GPU rendering.
surface = IMG_Load(joinpath(dirname(pathof(SimpleDirectMediaLayer)), "..", "assets", "cat.png"))
tex = SDL_CreateTextureFromSurface(renderer, surface)
SDL_FreeSurface(surface)

w_ref, h_ref = Ref{Cint}(0), Ref{Cint}(0)
# QueryTexture queries the pixel format of the Surface (which can be different CPU vs. Texture on GPU)
# This is querying the width and height of the loaded texture, filling their values into w_ref and h_ref. We dereference those Refs in the try block
# just once, because we only need the height, width at the beginning.
SDL_QueryTexture(tex, C_NULL, C_NULL, w_ref, h_ref)

try
    w, h = w_ref[], h_ref[]
    x = (1000 - w) ÷ 2
    y = (1000 - h) ÷ 2
    # NOTE: (0, 0) is the top-left corner in SDL (of a Texture, of the Window, etc)
    dest_ref = Ref(SDL_Rect(x, y, w, h))
    close = false
    speed = 300
    while !close
        event_ref = Ref{SDL_Event}()
        while Bool(SDL_PollEvent(event_ref))
            evt = event_ref[]
            evt_ty = evt.type
            if evt_ty == SDL_QUIT
                close = true
                break
            elseif evt_ty == SDL_KEYDOWN
                scan_code = evt.key.keysym.scancode
                if scan_code == SDL_SCANCODE_W || scan_code == SDL_SCANCODE_UP
                    y -= speed / 30
                    break
                elseif scan_code == SDL_SCANCODE_A || scan_code == SDL_SCANCODE_LEFT
                    x -= speed / 30
                    break
                elseif scan_code == SDL_SCANCODE_S || scan_code == SDL_SCANCODE_DOWN
                    y += speed / 30
                    break
                elseif scan_code == SDL_SCANCODE_D || scan_code == SDL_SCANCODE_RIGHT
                    x += speed / 30
                    break
                else
                    break
                end
            end
        end

        x + w > 1000 && (x = 1000 - w;)
        x < 0 && (x = 0;)
        y + h > 1000 && (y = 1000 - h;)
        y < 0 && (y = 0;)

        dest_ref[] = SDL_Rect(x, y, w, h)
        SDL_RenderClear(renderer)
        SDL_RenderCopy(renderer, tex, C_NULL, dest_ref)
        dest = dest_ref[]
        x, y, w, h = dest.x, dest.y, dest.w, dest.h
        SDL_RenderPresent(renderer)

        SDL_Delay(1000 ÷ 60)
    end
finally
    SDL_DestroyTexture(tex)
    SDL_DestroyRenderer(renderer)
    SDL_DestroyWindow(win)
    # shutdown all subsystems initialized by SDL_Init(...)
    SDL_Quit()
end