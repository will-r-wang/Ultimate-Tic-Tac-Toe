require_relative 'game'

class MarkdownGenerator

  IMAGE_BASE_URL = 'https://raw.githubusercontent.com/will-r-wang/Ultimate-Tic-Tac-Toe/master/images'

  O_IMAGE = "![](#{IMAGE_BASE_URL}/o.png)"
  X_IMAGE = "![](#{IMAGE_BASE_URL}/x.png)"
  EMPTY_IMAGE = "![](#{IMAGE_BASE_URL}/empty.png)"

  def initialize(game:)
    @game = game
  end

  def readme
    markdown = <<~HTML
        ## :game_die: Welcome to our community Ultimate Tic Tac Toe game! 👋
        Everyone is welcome to participate! To make a move, submit an issue with format "move|{row}|{col}".
    HTML

    markdown.concat(generate_game_board)
    markdown
  end

  attr_reader :game

  def generate_game_board
    headers = ' |0|1|2|3|4|5|6|7|8'
    game_board = "|#{headers}|\n| - | - | - | - | - | - | - | - | - | - |\n"

    0.upto(8) do |row|
      format = (0...8).map do |col|
        if game.board[row][col] == 'X'
          X_IMAGE
        elsif game.board[row][col] == 'O'
          O_IMAGE
        else
          EMPTY_IMAGE
        end
      end
      game_board.concat("|#{row}|#{format.join('|')}|\n")
    end
    game_board
  end
end
