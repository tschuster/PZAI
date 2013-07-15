require File.expand_path('../config/default', __FILE__)
@config[:nickname] = ARGV.first if ARGV.first.present?

host = Host.new(@config)
host.connect_to_lobby!

min_players = @config[:min_players]
current_players = []
i_am_leader = nil

while current_players.count < @config[:min_players]
  players = host.receive!
  fail("response timed out") unless players
  fail("response invalid") unless players.is_a?(Hash) || players[:nicknames].present?
  current_players = players[:nicknames]
puts "#{players[:nickname]} joined" if players[:nickname] != @config[:nickname]
puts "players in lobby: #{current_players.sort.join(", ")}"
  other_players = current_players - [@config[:nickname]]
  i_am_leader = current_players.count == 1 && players[:nickname] == @config[:nickname] if i_am_leader.nil?
  break unless i_am_leader
end

puts "awaiting ready state..."
  game_started = false
  wave_counter = 0
  host.send({request: "ready"}) unless i_am_leader
  players_ready = i_am_leader ? [@config[:nickname]] : []
  survivor = Survivor.new({})
  loop {
    message = host.receive!
    break unless message
    survivor.update_values(:hp => message[:hps].delete(@config[:nickname])) if message[:hps].present?
    if message[:response] == "ready" && !game_started
      players_ready << message[:nickname]
      players_ready.uniq!
      if players_ready.count == 1
        puts message[:nickname] == @config[:nickname] ? "you are ready" : "#{message[:nickname]} is ready"
      else
        puts "players ready: #{players_ready.sort.join(", ")}"
      end
      if players_ready.count == current_players.count
        puts "all players ready, starting game..."
        host.send({request: "start"})
        game_started = true
      end
    elsif message[:response] == "wave_approaching"
      wave_counter += 1
      draw_screen(message[:response], {wave_counter: wave_counter, nickname: @config[:nickname], hp: survivor.hp, team_hp: message[:hps], message: message})
    elsif message[:response] == "wave_starting"
      draw_screen(message[:response], {wave_counter: wave_counter, nickname: @config[:nickname], hp: survivor.hp, team_hp: message[:hps], message: message})
      survivor.handle_zombies(message, host, i_am_leader, other_players)
    elsif message[:response] == "attack_finished"
      draw_screen(message[:response], {wave_counter: wave_counter, nickname: @config[:nickname], hp: survivor.hp, team_hp: message[:hps], message: message})
    elsif message[:response] == "wave_finished"
      draw_screen(message[:response], {wave_counter: wave_counter, nickname: @config[:nickname], hp: survivor.hp, team_hp: message[:hps], message: message})
    end
  }