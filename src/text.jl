# structs and utilities for rendering text.

# manage access to a given font; creating fonts for sizes
mutable struct FontManager
    path::String
    fonts::Dict{Int, Ptr{TTF_Font}}
    # create destructor to free fonts
    function FontManager(path, fonts)
        x = new(path, fonts)
        # create finalizer to close fonts when this struct has no more refs
        function f(t)
            @async @debug "Destroying $t"
            cleanup(t)
        end
        finalizer(f, x)
    end
end
FontManager(path::String) = FontManager(path, Dict{Int, Ptr{TTF_Font}}())

function get_font(mgr::FontManager, size::Int)
    # load / retrieve a font for a given font size
    return get!(mgr.fonts, size, call_SDL(() -> TTF_OpenFont(mgr.path, size), res -> res != C_NULL))
end

function cleanup(mgr::FontManager)
    for font in values(mgr.fonts)
        TTF_CloseFont(font)
    end
end


mutable struct TextDrawable
    texture::Ptr{SDL_Texture}
    function TextDrawable(txtr)
        x = new(txtr)
        # create finalizer to destroy texture when this struct has no more refs
        function f(t)
            @async @debug "Destroying $t"
            SDL_DestroyTexture(t.texture)
        end
        finalizer(f, x)
    end
end
function TextDrawable(renderer, font, color, text)
    # create surface, convert to texture, then cleanup
    surf = TTF_RenderUTF8_Solid(font, text, color)
    txtr = SDL_CreateTextureFromSurface(renderer, surf)
    SDL_FreeSurface(surf)
    return TextDrawable(txtr)
end

function height(text::TextDrawable)
    h_ref = Ref{Int32}()
    call_SDL(() -> SDL_QueryTexture(text.texture, C_NULL, C_NULL, C_NULL, h_ref), res -> res == 0)
    return h_ref[]
end
function width(text::TextDrawable)
    w_ref = Ref{Int32}()
    call_SDL(() -> SDL_QueryTexture(text.texture, C_NULL, C_NULL, w_ref, C_NULL), res -> res == 0)
    return w_ref[]
end

