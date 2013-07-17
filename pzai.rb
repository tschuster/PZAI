require File.expand_path('../config/default', __FILE__)
@config[:nickname] = ARGV.first if ARGV.first.present?

@env = {
  min_players: @config[:min_players],
  nickname: @config[:nickname],
  current_players: [],
  i_am_leader: nil,
  host: Host.new(@config),
  game_started: false
}
draw_start_screen!
sleep(2)
draw_start_screen!("Connecting to host...")
@env[:host].connect_to_lobby!
draw_start_screen!("Entering lobby...")

while current_players.count < @env[:min_players]
  players = @env[:host].receive!
  fail("response timed out") unless players
  fail("response invalid") unless players.is_a?(Hash) || players[:nicknames].present?
  @env[:current_players] = players[:nicknames].sort
  draw_lobby!(players[:nickname] != @env[:nickname] ? players[:nickname] : nil)
  other_players = @env[:current_players] - [@env[:nickname]]
  @env[:i_am_leader] = @env[:current_players].count == 1 && players[:nickname] == @env[:nickname] if @env[:i_am_leader].nil?
  break unless @env[:i_am_leader]
end

puts "awaiting ready state..."
  @env[:wave_counter] = 0
  @env[:host].send({request: "ready"}) unless @env[:i_am_leader]
  players_ready = @env[:i_am_leader] ? [@env[:nickname]] : []
  @env[:survivor] = Survivor.new({}) if @env[:survivor].blank?
  loop {
    message = @env[:host].receive!
    break unless message
    @env[:message] = message
    @env[:survivor].update_values(:hp => message[:hps].delete(@config[:nickname])) if message[:hps].present?
    if message[:response] == "ready" && !@env[:game_started]
      players_ready << message[:nickname]
      players_ready.uniq!
      if players_ready.count == 1
        puts message[:nickname] == @config[:nickname] ? "you are ready" : "#{message[:nickname]} is ready"
      else
        puts "players ready: #{players_ready.sort.join(", ")}"
      end
      if players_ready.count == current_players.count
        puts "all players ready, starting game..."
        @env[:host].send({request: "start"})
        @env[:game_started] = true
      end
    elsif message[:response] == "wave_approaching"
      @env[:team_hp] = message[:hps]
      @env[:wave_counter] += 1
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