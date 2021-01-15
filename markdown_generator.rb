require_relative 'game'

class MarkdownGenerator
  ISSUE_BASE_URL = 'https://github.com/sayohnahilan/Ultimate-Tic-Tac-Toe/issues/new'
  IMAGE_BASE_URL = 'https://github.com/sayohnahilan/Ultimate-Tic-Tac-Toe/blob/main/images'
  ISSUE_BODY = 'body=Just+push+%27Submit+new+issue%27+without+editing+the+title.+The+README+will+be+updated+after+approximately+30+seconds.'

  O_IMAGE = "![](#{IMAGE_BASE_URL}/o.png)"
  X_IMAGE = "![](#{IMAGE_BASE_URL}/x.png)"
  EMPTY_IMAGE = "![](#{IMAGE_BASE_URL}/empty.png)"

  def initialize(game:)
    @game = game
  end

  def readme
    markdown = <<~HTML
        ## :game_die: Welcome to our community Ultimate Tic Tac Toe game! 👋
        Everyone is welcome to participate! To make a move, click on the board where valid.
    HTML

    markdown.concat(generate_game_board)
    markdown.concat("\nInspired by: [Community Connect Four Game!](https://github.com/JonathanGin52/JonathanGin52/)")
    markdown
  end

  attr_reader :game

  def generate_game_board
    headers = ' |0|1|2|3|4|5|6|7|8'
    game_board = "|#{headers}|\n|-|-|-|-|-|-|-|-|-|-|\n"

    0.upto(8) do |row|
      format = (0...9).map do |col|

        if game.valid_moves.include?("#{row}|#{col}")
          "[move](#{ISSUE_BASE_URL}?title=move%7C#{row}%7C#{col}&#{ISSUE_BODY})"
        elsif game.board[row][col] == 'X'
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
