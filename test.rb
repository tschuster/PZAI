require File.expand_path('../config/default', __FILE__)
def draw_screen(type)
  team_member_count = @env[:team_hp].count+1
  system "tput clear"
  puts "Wave: #{@env[:wave_counter]}"
  puts
  case type.to_s
  when "wave_approaching"
    puts "    Warning! Zombies on approach! Get Ready!"
  when "wave_starting"
    puts "    ZOMBIES!!!"
  when "attack_finished"
    puts "    your attack is over. the remaining zombies are attacking."
  when "wave_finished"
    puts "    wave is over, but they will return..."
  else
    puts type
  end
  puts
  puts
  line = "┏━"
  team_member_count.times do |i|
    line << "━"*10
    line << (i+1 < team_member_count ? "━┳━" : "━┓")
  end

  puts line
  line = "┃ #{@env[:nickname].ljust(10)} ┃ "
  line << @env[:team_hp].map {|member, hp| "#{member.ljust(10)} " }.join("┃ ")
  line << "┃"
  puts line
  line = "┃ HP: #{@env[:hp].to_s.rjust(6)} ┃ "
  line << @env[:team_hp].map {|member, hp| "HP: #{hp.to_s.rjust(6)} " }.join("┃ ") << "┃"
  puts line
  line = "┗━"
  team_member_count.times do |i|
    line << "━"*10
    line << (i+1 < team_member_count ? "━┻━" : "━┛")
  end
  puts line
  puts 
#  puts @env[:message][:enemies]
end

def draw_start_screen!(message="")
  system "tput clear"
  draw_upper_border
  8.times do
    draw_line
  end
  draw_with_border "          ########    ####    ##      ##  ######   ####  #####   #####"
  draw_with_border "          #    ##   ##    ##  ####  ####  ##   ##   ##   ##     ##   ##"
  draw_with_border "              ##    ##    ##  ## #### ##  ##   ##   ##   ##     ##"
  draw_with_border "             ##     ##    ##  ##  ##  ##  ######    ##   ####    #####"
  draw_with_border "            ##      ##    ##  ##      ##  ##   ##   ##   ##          ##"
  draw_with_border "           ##    #  ##    ##  ##      ##  ##   ##   ##   ##     ##   ##"
  draw_with_border "          ########    ####    ##      ##  ######   ####  #####   #####"
  if message.present?
    4.times do
      draw_line
    end
    draw_centered(message)
    4.times do
      draw_line
    end
  else
    9.times do
      draw_line
    end
  end
  draw_with_border(" "*30 << "A Zombie Apocalypse Survivor AI by T.Schuster".rjust(50))
  draw_with_border(" "*50 << "Version #{@version}".rjust(30))
  draw_lower_border
end

def draw_lobby!(player_entered = nil)
  system "tput clear"
  draw_upper_border
  lines = 1
  2.times do
    draw_line
    lines += 1
  end
  draw_centered("Game Lobby")
  lines += 1
  if player_entered.present?
    2.times do
      draw_line
      lines += 1
    end
    draw_centered("#{player_entered} entered the lobby")
    lines += 1
    (17-@env[:min_players]).times do
      draw_line
      lines += 1
    end
  else
    (20-@env[:min_players]).times do
      draw_line
      lines += 1
    end
  end
  draw_with_connected_border(("┏"<<"━"*46).rjust(80), :right)
  lines += 1
  draw_with_border(("┃" << " Players".ljust(39) << "Status ").rjust(80))
  lines += 1
  draw_with_connected_border(("┣" <<"━"*46).rjust(80), :right)
  lines += 1
  draw_with_border(("┃" << " #{@env[:nickname]}".ljust(40) << "Ready ").rjust(80))
  lines += 1
  (@env[:current_players] - [@env[:nickname]]).each do |nickname|
    draw_with_border(("┃" << " #{nickname}".ljust(38) << "Waiting ").rjust(80))
    lines += 1
  end
  (@env[:min_players]-@env[:current_players].count-1).times do
    draw_with_border(("┃" << " "*(46)).rjust(80))
    lines += 1
  end
  draw_lower_border
end

def draw_with_border(message)
  puts "┃" << message.ljust(80) << "┃"
end

def draw_with_connected_border(message, direction = :left)
  if direction == :left
    puts "┣" << message.ljust(80) << "┃"
  else
    puts "┃" << message.ljust(80) << "┫"
  end
end

def draw_upper_border
  puts "┏" << "━"*80 << "┓"
end

def draw_lower_border
  puts "┗" << "━"*80 << "┛"
end

def draw_line
  puts "┃" << " "*80 << "┃"
end

def draw_centered(message)
  puts "┃" << (" "*(40-message.length/2) << message).ljust(80) << "┃"
end

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
draw_lobby!("Weasel")
sleep(2)
@env[:current_players] = ["Alice"]
draw_lobby!("Alice")
sleep(2)
@env[:current_players] = ["Alice", "Bob"]
draw_lobby!("Bob")
sleep(2)
@env[:current_players] = ["Charlie", "Alice", "Bob"]
draw_lobby!("Charlie")