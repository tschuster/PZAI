require 'socket'
class Host
  def initialize(url, port)
    @url = url
    @port = port
  end

  def connect!
    begin
      @socket = TCPSocket.new(@url, @port)
    rescue
      @socket = nil
      Rails.logger.info("######## Socket connect error to #{@url}:#{@port}")
      return false
    end
    true
  end

  def disconnect!
    @socket.close if @socket.present? && !@socket.closed?
  end

  def send(data)
    if data.is_a?(Hash)
      data = data.to_json
    end
    data << "\n"
    begin
      @socket.write(data)
    rescue
      Rails.logger.info("######## Socket write error on #{data}")
      return false
    end
    true
  end

  def receive!(timeout=nil)
    begin
      ready = IO.select([@socket], nil, nil, timeout || 60)
      if ready
        response = @socket.gets
        JSON.parse(response.squish)
      else
        return false
      end
    rescue
      Rails.logger.info("######## Socket read error")
      {}
    end
  end

  def send_to(receiver, message, payload=nil)
    data = {message: message}
    data[:payload] = payload if payload.present?
    begin
      if receiver.is_a?(Array)
        receiver.each do |nickname|
          data[:receiver] = nickname
          @socket.write(data.to_json << "\n")
        end
      else
        data[:receiver] = receiver
        @socket.write(data.to_json << "\n")
      end
    rescue
      Rails.logger.info("######## Socket write error on #{data}")
      return false
    end
    true
  end
end