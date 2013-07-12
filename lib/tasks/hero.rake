namespace :hero do

  task :start => :environment do

    config = {
      nickname: "test",
      url: "<my_url_here>",
      port: 111111,
      min_players: 10
    }

    # connection
puts "connecting..."
    host = Host.new(config[:url], config[:port])
    result = host.connect!
    abort("failed to connect") unless result

    # preparing game
puts "preparing..."
    min_players = config[:min_players]
    current_players = []

    # login
puts "login..."
    result = A11n.login(host, config[:nickname])
    abort("failed to login") unless result

    while current_players.count < config[:min_players]
      players = host.receive!
      abort("response timed out") unless players
      abort("response invalid") unless players.is_a?(Hash) || players["Nicknames"].present?
      current_players = players["Nicknames"]
puts "players in lobby: #{current_players.sort}"
      other_players = current_players - [config[:nickname]]
      i_am_leader = current_players.count == 1 && current_players.first == config[:nickname]
      break unless i_am_leader
    end

    if i_am_leader
puts "starting game..."
      host.send({request: "start_game"})
    else
puts "awaiting game start..."
      host.send({request: "ready"})
      loop {
        message = host.receive!
puts message
      }
    end

    # ending
puts "closing connection..."
    host.disconnect!
  end
end