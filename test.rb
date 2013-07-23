require File.expand_path('../config/default', __FILE__)

@version = "0.0.1"
@env = {
  min_players: 8,
  nickname: "Weasel",
  current_players: ["Alice", "Bob"],
  i_am_leader: true,
  survivor: Survivor.new({hp: 100}),
  host: nil,
  game_started: false,
  wave_counter: 20,
  team_hp: {"Alice" => 50, "Weasel" => 100, "Bob" => 100}
}
@env[:current_players] = []
draw_start_screen!