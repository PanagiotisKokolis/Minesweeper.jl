# define the entrypoint for the binary executable, created by PackageCompiler

function julia_main()::Cint
    try
        launch()
    catch e
        @error "Error in main loop: $e"
        @error "Backtrace: $(e.backtrace)"
        return 1
    end
    return 0
end