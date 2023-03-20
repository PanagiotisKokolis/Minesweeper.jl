
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
        N, M = (30, 16)
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

function is_game_over(game::MinesweeperGame)::Bool
    # check if any opened cell contains a mine
    return any(game.mines[game.states .== opened])
end