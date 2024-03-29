require_relative 'octokit_client'
require_relative 'game'
require_relative 'markdown_generator'

module UltimateTicTacToe
  class Runner
    class InvalidMoveError < StandardError; end
    class InvalidCommandError < StandardError; end

    GAME_DATA_PATH = 'game_data.yml'
    README_PATH = 'README.md'

    def initialize(github_token:, issue_number:, issue_title:, repository:, user:)
      @github_token = github_token
      @repository = repository
      @issue_number = issue_number
      @issue_title = issue_title
      @user = user
    end

    def run
      split_input = @issue_title.split('|')
      command = split_input[0]

      acknowledge_issue

      if command == 'move'
        row, col = split_input[1], split_input[2]
        @game = Game.load(Base64.decode64(raw_game_data.content))
        @game.make_move(Integer(row), Integer(col))
        handle_game_over if @game.game_over?
      elsif command == 'new'
        @game = Game.new(board: '#' * 81, meta: '#' * 9)
      else
        raise InvalidCommandError, "unrecognized command"
      end

      write_game_state(command: command)
    rescue InvalidMoveError => error
      comment = "#{row}|#{col} is an invalid move. Please check the board and try again."
      octokit.error_notification(reaction: 'confused', comment: comment, error: error)
    rescue InvalidCommandError => error
      comment = "#{command} is an invalid command. Please check the board and try again. You should not need to change the issue title"
      octokit.error_notification(reaction: 'confused', comment: comment, error: error)
    rescue ArgumentError, TypeError => error
      comment = "#{row}|#{col} is not an Integer parsable move. Please check the board and try again."
      octokit.error_notification(reaction: 'confused', comment: comment, error: error)
    end

    def handle_game_over
      @game = Game.new(board: '#' * 81, meta: '#' * 9)
    end

    def acknowledge_issue
      octokit.add_label(label: 'ultimate-tic-tac-toe')
      octokit.add_reaction(reaction: 'eyes')
      octokit.close_issue
    end

    def write_game_state(command:)
      File.write(GAME_DATA_PATH, @game.serialize)
      File.write(README_PATH, generate_readme)

      message = if command == 'move'
        "@#{@user} made a move!"
      else
        "@#{@user} started a new game!"
      end

      `git add #{GAME_DATA_PATH} #{README_PATH}`
      `git config --global user.email "github-action-bot@example.com"`
      `git config --global user.name "GitHub Action Bot"`
      if system("git commit -m '#{message}'") && system('git push')
        octokit.add_reaction(reaction: 'rocket')
      else
        comment = "Oh no! There was a network issue. This is a transient error. Please try again!"
        octokit.error_notification(reaction: 'confused', comment: comment)
      end
    end

    def generate_readme
      MarkdownGenerator.new(game: @game).readme
    end

    def raw_game_data
      @raw_game_data ||= octokit.fetch_from_repo(GAME_DATA_PATH)
    end

    def octokit
      @octokit ||= OctokitClient.new(github_token: @github_token, repository: @repository, issue_number: @issue_number)
    end
  end
end
