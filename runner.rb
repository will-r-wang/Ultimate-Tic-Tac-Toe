require_relative 'octokit_client'
require_relative 'game'

module UltimateTicTacToe
  class Runner
    class InvalidCommandError < StandardError; end

    GAME_DATA_PATH = 'game_data.yml'

    def initialize(
      github_token:,
      issue_number:,
      issue_title:,
      repository:
    )
      @github_token = github_token
      @repository = repository
      @issue_number = issue_number
      @issue_title = issue_title
    end

    def run
      split_input = @issue_title.split('|')
      command = split_input[0]

      acknowledge_issue

      if command == 'move'
        row, col = split_input[1], split_input[2]
        @game = Game.load(Base64.decode64(raw_game_data.content))
        @game.make_move(Integer(row), Integer(col))
      elsif command == 'new'
        @game = Game.new('#' * 81, '#' * 9)
      else
        raise InvalidCommandError, "unrecognized command"
      end

      write_game_state
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

    def acknowledge_issue
      octokit.add_label(label: 'ultimate-tic-tac-toe')
      octokit.add_reaction(reaction: 'eyes')
      octokit.close_issue
    end

    def write_game_state
      File.write(GAME_DATA_PATH, @game.serialize)
      `git add #{GAME_DATA_PATH}`
      `git config --global user.email "github-action-bot@example.com"`
      `git config --global user.name "GitHub Action Bot"`
      if system("git commit -m test1") && system('git push')
        octokit.add_reaction(reaction: 'rocket')
      else
        comment = "Oh no! There was a network issue. This is a transient error. Please try again!"
        octokit.error_notification(reaction: 'confused', comment: comment)
      end
    end

    def raw_game_data
      @raw_game_data ||= octokit.fetch_from_repo(GAME_DATA_PATH)
    end

    def octokit
      @octokit ||= OctokitClient.new(github_token: @github_token, repository: @repository, issue_number: @issue_number)
    end
  end
end
