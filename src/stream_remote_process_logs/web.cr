require "kemal"
require "redis"

require "./processes"

module StreamRemoteProcessLogs
  module Web
    @@redis : Redis::Client? = nil

    get "/" do
      render "src/stream_remote_process_logs/views/index.ecr"
    end

    ws "/process/:id" do |socket, context|
      process_id = context.ws_route_lookup.params["id"]
      channel_id = Processes.command_channel_id(process_id)

      offset = "-"

      loop do
        messages = redis.xrange(channel_id, offset, "+")
        messages.each do |message|
          next unless message.is_a?(Array(Redis::Value))

          offset = message[0].to_s
          content = message[1]
          next unless content.is_a?(Array(Redis::Value))

          socket.send({message: content[1].to_s}.to_json)
        end

        sleep(1)
      end
    end

    def self.init(redis : Redis::Client)
      @@redis = redis
    end

    def self.redis : Redis::Client
      @@redis.try do |redis|
        return redis
      end

      raise "Redis client not configured"
    end

    def self.serve(port : Int)
      Kemal.run(port: port)
    end
  end
end
