require "kemal"
require "redis"

module StreamRemoteProcessLogs
  module Web
    get "/" do
      render "src/views/index.ecr"
    end

    ws "/command/:id" do |socket, context|
      command_id = context.ws_route_lookup.params["id"]

      redis = Redis.new
      redis.subscribe(command_id) do |on|
        on.message do |_channel, message|
          socket.send({ message: message }.to_json)
        end
      end
    end

    def self.serve(port : Int)
      Kemal.run(port: port)
    end
  end
end
