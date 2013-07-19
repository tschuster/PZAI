def players_ready
  result = []
  @env[:current_players].each_pair do |nickname, data|
    result << nickname if data[:state] == :ready
  end
  result
end

def players_count
  @env[:current_players].keys.count
end

def leader?
  !!@env[:i_am_leader]
end

def game_started?
  @env[:game_started]
end