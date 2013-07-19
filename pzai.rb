require File.expand_path('../config/default', __FILE__)
@config[:nickname] = ARGV.first if ARGV.first.present?

@env = {
  min_players: @config[:min_players],
  nickname: @config[:nickname],
  current_players: {},
  i_am_leader: nil,
  host: Host.new(@config),
  game_started: false
}
draw_start_screen!
sleep(2)
draw_start_screen!("Connecting to host...")
@env[:host].connect_to_lobby!
draw_start_screen!("Entering lobby...")

while players_count < @env[:min_players]
  players = @env[:host].receive!
  fail("response timed out") unless players
  fail("response invalid") unless players.is_a?(Hash) || players[:nicknames].present?
  @env[:current_players] = {}
  players[:nicknames].sort.each do |nickname|
    @env[:current_players][nickname] = {}
  end
  draw_lobby!(players[:nickname] != @env[:nickname] ? "#{players[:nickname]} entered the lobby" : nil)
  @env[:i_am_leader] = (players_count == 1 && players[:nickname] == @env[:nickname]) if @env[:i_am_leader].nil?
  break unless leader?
end

draw_lobby!("awaiting readystate...")
@env[:wave_counter] = 0
@env[:host].send({request: "ready"}) unless leader?
players_ready = leader? ? [@env[:nickname]] : []
@env[:survivor] = Survivor.new({}) if @env[:survivor].blank?

# start game loop
loop {
  message = @env[:host].receive!
  break unless message
  @env[:message] = message
  if message[:hps].present?
    @env[:survivor].update_values(:hp => message[:hps].delete(@config[:nickname]))
    message[:hps].each_pair do |nickname, hp|
      @env[:current_players][:nickname][:hp] = hp
    end
  end

  if message[:response] == "ready" && !game_started?
    @env[:current_players][message[:nickname]][:state] = :ready
    draw_lobby!
    if players_ready.count == players_count
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
    survivor.handle_zombies(message, host, leader?, other_players)
  elsif message[:response] == "attack_finished"
    draw_screen(message[:response], {wave_counter: wave_counter, nickname: @config[:nickname], hp: survivor.hp, team_hp: message[:hps], message: message})
  elsif message[:response] == "wave_finished"
    draw_screen(message[:response], {wave_counter: wave_counter, nickname: @config[:nickname], hp: survivor.hp, team_hp: message[:hps], message: message})
  end
}