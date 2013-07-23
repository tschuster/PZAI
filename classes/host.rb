class Host < BasicObject
  def initialize(config)
    @nickname = config[:nickname]
    @url = config[:url]
    @port = config[:port]
    @logger = ::Logger.new("log/host.log")
  end

  def connect_to_lobby!
    fail "nickname not set" if @nickname.blank?
    begin
      @socket = ::TCPSocket.new(@url, @port)
      log("Socket connected to #{@url}:#{@port}")
      send({nickname: @nickname, request: "new_game"})
    rescue
      @socket = nil
      log("Socket unable to connect to #{@url}:#{@port}", :error)
      return false
    end
    true
  end

  def disconnect!
    begin
      send({nickname: @nickname, request: "exit"})
    ensure
      @socket.close if @socket.present? && @socket.open?
    end
  end

  def send(data)
    return false unless @socket.open?
    if data.is_a?(::Hash)
      data = data.to_json
    end
    data << "\n"
    begin
      bytes = @socket.write(data)
      log("Wrote #{bytes} bytes")
    rescue
      log("Unable to write #{data}", :error)
      return false
    end
    true
  end

  def receive!(timeout=nil)
    return false unless @socket.present? && @socket.open?
    begin
      ready = ::IO.select([@socket], nil, nil, timeout || 60)
      if ready
        response = @socket.gets
        log("Received #{response.length} bytes")
        ::JSON.parse(response.squish).symbolize_keys
      else
        return false
      end
    rescue
      log("Unable to read from Socket", :error)
      disconnect!
      {}
    end
  end

  def send_to(receiver, payload=nil)
    data = {request: "talk"}
    data[:data] = payload if payload.present?
    begin
      if receiver.is_a?(::Array)
        receiver.each do |nickname|
          data[:nickname] = nickname
          bytes = @socket.write(data.to_json << "\n")
          log("Wrote #{bytes} bytes")
        end
      else
        data[:nickname] = receiver
        bytes = @socket.write(data.to_json << "\n")
        log("Wrote #{bytes} bytes")
      end
    rescue
      log("Unable to write #{data}", :error)
      return false
    end
    true
  end

  protected

    def log(message, level=:info)
      @logger = ::Logger.new("log/host.log") if @logger.blank?
      @logger.send(level, message)
    end
end