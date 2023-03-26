# Minesweeper.jl
Julia Minesweeper(s)

## Compile Executable
You can create an executable binary for the game using `PackageCompiler`.

Use the following command:
```sh
create_app("Minesweeper.jl", "<CompileDirectory>"; precompile_execution_file="Minesweeper.jl/build/precompile_execution.jl")
```