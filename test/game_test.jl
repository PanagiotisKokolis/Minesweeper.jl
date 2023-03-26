
@testset "Game Tests" begin

    @testset "Game Creation" begin
        # create a game
        game = Minesweeper.create_game(:easy)
        # check that the game is the correct size
        @test Minesweeper.nrows(game) == 9
        @test Minesweeper.ncols(game) == 9
        # check that the game has the correct number of mines
        @test sum(game.mines) == 10
        # check that the game has the correct number of unopened cells
        @test sum(game.states .== Minesweeper.unopened) == 81
        # check that the game has the correct number of flagged cells
        @test sum(game.states .== Minesweeper.flagged) == 0
        # check that the game has the correct number of opened cells
        @test sum(game.states .== Minesweeper.opened) == 0
    end

end