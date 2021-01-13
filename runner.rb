require_relative 'octokit_client'
require_relative 'game'

module UltimateTicTacToe
  class Runner
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
      row = split_input[0]
      col = split_input[1]

      acknowledge_issue

      @game = Game.load(Base64.decode64(raw_game_data.content))
      @game.make_move(Integer(row), Integer(col))

      write_game_state
    end

    def acknowledge_issue
      octokit.add_label(label: 'ultimate-tic-tac-toe')
      octokit.add_reaction(reaction: 'eyes')
      octokit.close_issue
    end

    def write_game_state
      puts @game.serialize
      File.write(GAME_DATA_PATH, @game.serialize)
    end

    def raw_game_data
      @raw_game_data ||= octokit.fetch_from_repo(GAME_DATA_PATH)
    end

    def octokit
      @octokit ||= OctokitClient.new(github_token: @github_token, repository: @repository, issue_number: @issue_number)
    end
  end
end
