module UltimateTicTacToe
  class Game
    class InvalidMoveError < StandardError; end

    attr_reader :row_bound, :col_bound
    ROWS, COLS = 9, 9
    WIN_COMBINATIONS = [
      [0,1,2], # top_row
      [3,4,5], # middle_row
      [6,7,8], # bottom_row
      [0,3,6], # left_column
      [1,4,7], # center_column
      [2,5,8], # right_column
      [0,4,8], # left_diagonal
      [6,4,2] # right_diagonal
    ]

    def initialize(board:, meta:, turn:, row_bound: -1, col_bound: -1)
      @board = board.split("").each_slice(9).to_a
      @meta = meta.split("")
      @player = (turn % 2 == 0) ? 'X' : 'O'
      @row_bound = row_bound
      @col_bound = col_bound
    end

    def board_complete?(board)
      WIN_COMBINATIONS.each do |comb|
        return true if (comb - board.size.times.select { |idx| board[idx] == @player }).empty?
      end
      false
    end

    def print_board
      @board.each {|row| puts row.join("")}
    end

    def string_board
      @board.flatten.join("")
    end

    def string_meta
      @meta.join("")
    end

    def make_move(row, col)
      raise InvalidMoveError unless valid_move?(row, col)
      @board[row][col] = @player
      row_offset, col_offset = row % 3, col % 3
      row, col = row - (row % 3), col - (col % 3)
      if board_complete?(@board.map { |r| r[col...col+3] } [row...row+3].flatten.join(""))
        3.times { |r| 3.times { |c| @board[row + r][col + c] = @player } }
        @meta[row + col / 3] = @player
        @row_bound, @col_bound = -1, -1
      else
        @row_bound, @col_bound = row_offset, col_offset
      end
      return "GAME OVER" if board_complete?(@meta)
    end

    def valid_move?(row, col)
      return false if (col > COLS - 1 or row > ROWS - 1)
      return false unless @board[row][col] == '#'
      return true if @row_bound == -1 and @col_bound == -1
      return false unless row.between?(@row_bound * 3, @row_bound * 3 + 2) and
                          col.between?(@col_bound * 3, @col_bound * 3 + 2)
      true
    end
  end
end
