module UltimateTicTacToe
  class Game
    # we'll need to save data into a .yml file like Jonathan Gin and read it into this constructor
    # not going to be great cause I think it's going to need 81 characters at least
    def initialize(board: [], turn: 0, prev_move: nil)
      @board = board
      @turn = turn
    end

    def make_move(position)
      # if not valid_move?(position) raise Error
      # else
        # if win subboard --> check overall win
    end

    def valid_moves
      # return all valid moves for next player
    end

    def valid_move?
      # checks if cell is a valid move
    end

    def board_complete?
      # check if any 3 row of 3 by 3 subboards are complete
    end

    def subboard_complete?
      # checks a 3 by 3 grid to see if complete
    end
  end
end
