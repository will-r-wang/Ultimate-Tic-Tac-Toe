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

  def generate_game_board
    valid_moves = @game.valid_moves
  end

end
