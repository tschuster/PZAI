class Survivor
  require File.expand_path('../../helper/methods', __FILE__)
  def initialize(values, env)
    @hp = values[:hp].to_i
    @env = env
  end

  def hp
    @hp
  end

  def update_values(values)
    @hp = values[:hp]
  end

  def update_env(env)
    @env = env
  end

  def handle_zombies(message)
    message_from_other_players = nil

    # sort zombies by remaining hp and attack weakes enemy
    zombies = message[:enemies]
    weakest_hp = zombies.values.min
    zombie_id = zombies.keys.first
    zombies.each_pair do |id, hp|
      zombie_id = id
      break if hp == weakest_hp
    end
    if !!@env[:i_am_leader]
      @env[:host].send_to(other_players, {message: "attack_zombie", id: zombie_id})
    else
      waiter = 0
      while message_from_other_players.blank? && waiter < 3
        message_from_other_players = @env[:host].receive!
        waiter += 1
        break if waiter >= 3 || message_from_other_players.present?
        sleep(1)
      end
    end
    if message_from_other_players.present?
      log("message from other players:")
      if message_from_other_players[:response] == "talk"
        log("attacking zombie #{message_from_other_players[:data][:id]} as told")
        @env[:host].send(request: "attack", id: message_from_other_players[:data][:id]) if message_from_other_players[:data][:message] == "attack_zombie"
      end
      log(message_from_other_players)
    else
      log("attacking zombie #{zombie_id}")
      @env[:host].send(request: "attack", id: zombie_id)
    end
  end

  protected

    def log(message, level=:info)
      @logger = ::Logger.new("log/survivor.log") if @logger.blank?
      @logger.send(level, message)
    end
end