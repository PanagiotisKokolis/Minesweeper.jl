# basic io and menu functionality using SDL

# simple "game" loop: poll for arrow events, print out each arrow pressed, print escape when escape pressed, and countdown 5s then quit program

using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2


function main()

    SDL_Init(SDL_INIT_EVERYTHING)
    win = SDL_CreateWindow("Menu", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 640, 640, SDL_WINDOW_SHOWN)

    close = false
    escaped = false # track if escape has been pressed once
    while !close

        event_ref = Ref{SDL_Event}()

        # The event queue is a circular buffer; events are added FIFO, old events can be deleted if not popped off
        # while looping in this way will deplete the buffer before returning unless `break` is encountered
        while Bool(SDL_PollEvent(event_ref))
            event = event_ref[]

            # we want to handle several kinds of events: 
            # - ARROWS: Print the arrows that are pressed,
            # - ESCAPE: Print "are you sure you want to exit?" 
            # - ESCAPE 2: Exit the game.
            # - ELSE: Ignore other events

            if event.type == SDL_QUIT
                # SDL_QUIT is generated when the user clicks the close button of the LAST existing window
                close = true
                break
            elseif event.type == SDL_KEYDOWN
                # all keypresses 
                scancode = event.key.keysym.scancode
                if scancode == SDL_SCANCODE_ESCAPE
                    # if escaped is true, exit; else set escape to true
                    if escaped
                        close = true
                    else
                        println("Are you sure you want to exit? Press Escape again.")
                        escaped = true
                    end
                    break
                elseif scancode in (SDL_SCANCODE_UP, SDL_SCANCODE_LEFT, SDL_SCANCODE_RIGHT, SDL_SCANCODE_DOWN)
                    println("Arrow pressed: $(Symbol(scancode))")
                    # reset escaped 
                    escaped = false
                    break
                else
                    break
                end
            end
        end
    end

    SDL_DestroyWindow(win)
    SDL_Quit()

end

main()