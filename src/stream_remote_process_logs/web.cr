require "kemal"
require "redis"

require "./processes"

module StreamRemoteProcessLogs
  module Web
    get "/" do
      render "src/stream_remote_process_logs/views/index.ecr"
    end

    ws "/process/:id" do |socket, context|
      process_id = context.ws_route_lookup.params["id"]
      channel_id = Processes.command_channel_id(process_id)

      redis = Redis.new
      puts "Connecting to channel: #{channel_id}"
      redis.subscribe(channel_id) do |on|
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
