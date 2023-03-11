# basic io and menu functionality using SDL

# simple "game" loop: poll for arrow events, print out each arrow pressed, print escape when escape pressed, and countdown 5s then quit program

using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2


function main()

    SDL_Init(SDL_INIT_EVERYTHING)
    win = SDL_CreateWindow("Menu", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 640, 640, SDL_WINDOW_SHOWN)

    close = false
    while !close

        event_ref = Ref{SDL_Event}()

        while Bool(SDL_PollEvent(event_ref))
            event = event_ref[]

            if event.type == SDL_QUIT
                close = true
                break
            elseif event.type == SDL_KEYDOWN
                scan_code = event.key.keysym.scancode
                if scan_code == SDL_SCANCODE_ESCAPE
                    println("Escaped!")
                    close = true
                    break
                end
            else
                println("Received event $(event.type)")
                break
            end
        end
    end

    SDL_DestroyWindow(win)
    SDL_Quit()

end

main()