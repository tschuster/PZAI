def draw_screen(type, values)
  team_member_count = values[:team_hp].count+1
  system "tput clear"
  puts "Wave: #{values[:wave_counter]}"
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
  line = "┃ #{values[:nickname].ljust(10)} ┃ "
  line << values[:team_hp].map {|member, hp| "#{member.ljust(10)} " }.join("┃ ")
  line << "┃"
  puts line
  line = "┃ HP: #{values[:hp].to_s.rjust(6)} ┃ "
  line << values[:team_hp].map {|member, hp| "HP: #{hp.to_s.rjust(6)} " }.join("┃ ") << "┃"
  puts line
  line = "┗━"
  team_member_count.times do |i|
    line << "━"*10
    line << (i+1 < team_member_count ? "━┻━" : "━┛")
  end
  puts line
  puts 
  puts values[:message][:enemies]
end