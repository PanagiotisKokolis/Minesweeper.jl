
@enum CellState begin
    unopened
    opened
    flagged
end


"""
Represents a game of Minesweeper, parameterized by its size N x M.
"""
struct MinesweeperGame{N, M}
    # boards, each interesting property as a separate 2d array
    mines::SMatrix{N, M, Bool}
    states::MMatrix{N, M, CellState}
    hints::SMatrix{N, M, UInt8}
end

nrows(::MinesweeperGame{N, M}) where {N, M} = N
ncols(::MinesweeperGame{N, M}) where {N, M} = M

function create_game(difficulty)

    if difficulty == :easy
        N, M = (9, 9)
        n_mines = 10
    elseif difficulty == :intermediate
        N, M = (16, 16)
        n_mines = 40
    elseif difficulty == :expert
        N, M = (16, 30)
        n_mines = 99
    end
    # create game
    mines = init_mines(N, M, n_mines)
    return MinesweeperGame{N, M}(mines, init_states(N, M), init_hints(mines))
end

function init_mines(rows, cols, n_mines)
    # initialize the mine board
    inds = CartesianIndices((1:rows, 1:cols))
    mine_locs = first(randperm(length(inds)), n_mines)
    mines = zeros(Bool, rows, cols)
    mines[inds[mine_locs]] .= true

    return SMatrix{rows, cols}(mines)
end

function init_states(rows, cols)
    # initialize the state of each cell as unopened
    states = repeat([unopened], rows, cols)
    return MMatrix{rows, cols}(states)
end

function init_hints(mines::SMatrix{N, M}) where {N, M}
    # count the adjacent mines to each location on the board.
    hints = zeros(UInt8, N, M)
    inds = CartesianIndices(mines)
    for center in inds
        hints[center] = sum(getindex.(Ref(mines), neighbor_inds(N, M, center.I)))
    end

    return SMatrix{N, M}(hints)
end

function neighbor_inds(rows, cols, (row, col))
    return CartesianIndices((max(1, row-1):min(rows, row+1), max(1, col-1):min(cols, col+1)))
end

#reveal- click a location, check if mine, if zero flood fill, otherwise reveal
#  click as game input on a grid not pixel
#what does reveal need? Playstate, the square relative to the pixel clicked
# if cell state = unopened, set state to opened and check if is mine
# if cell state is opened, flagged, do nothing
# if is_mine true return gameover (-1)
# if ! is_mine  show hint.
function reveal(game::MinesweeperGame, rowi, colj)
    if game.states[rowi,colj] == unopened
        game.states[rowi,colj] = opened
        if game.mines[rowi,colj]
            return -1
        elseif game.hints[rowi,colj] == 0
            flood_fill(game, rowi, colj)
        end
    end
    return
end

function flood_fill(game::MinesweeperGame, rowi, colj)
    reveal_queue = []
    push!(reveal_queue, neighbor_inds(nrows(game), ncols(game), (rowi,colj))...)
    while !(isempty(reveal_queue))
        temp = popfirst!(reveal_queue)
        if game.states[temp] == unopened
            game.states[temp]= opened
            if game.hints[temp] == 0
                push!(reveal_queue, neighbor_inds(nrows(game), ncols(game), temp.I)...)
            end
        end
    end
    return
end

function is_game_over(game::MinesweeperGame)::Bool
    # check if any opened cell contains a mine
    return any(game.mines[game.states .== opened])
end