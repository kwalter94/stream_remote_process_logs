require "redis"

module StreamRemoteProcessLogs
  module Processes
    def self.run_process(command : String, args : Array(String))
      process_id = UUID.v4.to_s

      Process.run(command, args) do |process|
        redis = Redis.new
        channel_id = "commands:#{process_id}"
        puts("Publishing to channel: #{channel_id}")

        process.output.each_line do |line|
          redis.publish(channel_id, line)
        end
      end
    end
  end
end
