require 'yaml'

module UltimateTicTacToe
  class Game
    class InvalidMoveError < StandardError; end

    attr_reader :board

    ROWS, COLS = 9, 9
    WIN_COMBINATIONS = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [6,4,2]]

    def initialize(board:, meta:, turn: 0, row_bound: -1, col_bound: -1)
      @board = board.split("").each_slice(9).to_a
      @meta = meta
      @turn = turn
      @player = (turn % 2 == 0) ? 'X' : 'O'
      @row_bound = row_bound
      @col_bound = col_bound
    end

    def self.load(data)
      Game.new(**YAML.load(data))
    end

    def board_complete?(board)
      WIN_COMBINATIONS.each do |comb|
        return true if (comb - board.size.times.select { |idx| board[idx] == @player }).empty?
      end
      false
    end

    def serialize
      {
        board: @board.flatten.join(""),
        meta: @meta,
        turn: @turn,
        row_bound: @row_bound,
        col_bound: @col_bound,
      }.to_yaml
    end

    def make_move(row, col)
      raise InvalidMoveError, 'move invalid' unless valid_move?(row, col)
      @board[row][col] = @player
      @turn += 1
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

    def valid_moves
      9.times.collect { |r| 9.times.collect { |c| "#{r}|#{c}" if valid_move?(r,c) } }.flatten.compact.join(",")
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
