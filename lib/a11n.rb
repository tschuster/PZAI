class A11n

  class << self

    def login(host, nickname)
      data = {nickname: nickname, request: "new_game"}
      host.send(data)
    end

    def logout(host, nickname)
      data = {nickname: nickname, request: "exit"}
      host.send(data)
    end

  end
end