def fail(message)
  ::Logger.new("log/error.log").send(:error, message)
  super(message)
end

def draw_game(message)
  system "tput clear"
  draw_upper_border
  lines = 1
  draw_with_border
  lines += 1
  draw_centered "Wave #{@env[:wave_counter]}"
  lines += 1
  while lines <= 28 do
    draw_with_border
    lines += 1
  end
  draw_lower_border
end

def draw_screen(type)
  
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
  
  system "tput clear"
  draw_upper_border
  lines = 1
  draw_with_border
  lines += 1
  draw_with_border
  lines += 1
  line = "┣━"
  team_member_count.times do |i|
    line << "━"*10
    line << (i+1 < team_member_count ? "━┳━" : "━┫")
  end

  puts line
  lines += 1
  line = "┃ #{@env[:nickname].ljust(10)} ┃ "
  line << @env[:team_hp].map {|member, hp| "#{member.ljust(10)} " }.join("┃ ")
  line << "┃"
  puts line
  lines += 1
  line = "┃ HP: #{@env[:hp].to_s.rjust(6)} ┃ "
  line << @env[:team_hp].map {|member, hp| "HP: #{hp.to_s.rjust(6)} " }.join("┃ ") << "┃"
  puts line
  lines += 1
  line = "┗━"
  players_count.times do |i|
    line << "━"*10
    line << (i+1 < team_member_count ? "━┻━" : "━┛")
  end
  puts line
  lines += 1
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

def draw_lobby!(message = "")
  system "tput clear"
  draw_upper_border
  lines = 1
  2.times do
    draw_line
    lines += 1
  end
  draw_centered("Game Lobby")
  lines += 1
  if @env[:player_entered].present?
    2.times do
      draw_line
      lines += 1
    end
    draw_centered(message)
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
  (@env[:current_players].keys - [@env[:nickname]]).each do |nickname|
    draw_with_border(("┃" << " #{nickname}".ljust(38) << "Waiting ").rjust(80))
    lines += 1
  end
  (@env[:min_players]-@env[:current_players].count).times do
    draw_with_border(("┃" << " "*(46)).rjust(80))
    lines += 1
  end
  draw_lower_border
end

def draw_with_border(message = "")
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

def draw_centered(message="")
  puts "┃" << (" "*(40-message.length/2) << message).ljust(80) << "┃"
end