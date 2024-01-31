require "redis"

module StreamRemoteProcessLogs
  module Processes
    def self.run_process(redis : Redis::Client, command : String, args : Array(String))
      process_id = UUID.v4.to_s
      puts "Starting new process: #{process_id}"

      Process.run(command, args) do |process|
        channel_id = command_channel_id(process_id)
        puts("Publishing to channel: #{channel_id}")

        process.output.each_line do |line|
          redis.xadd(channel_id, "*", "1000", {"message" => line})
        end
      end
    end

    def self.command_channel_id(process_id : String) : String
      "commands:#{process_id}"
    end
  end
end
