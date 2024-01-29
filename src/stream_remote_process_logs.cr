require "option_parser"
require "uuid"

require "./stream_remote_process_logs/processes"
require "./stream_remote_process_logs/web"

module StreamRemoteProcessLogs
  VERSION = "0.1.0"

  command : Symbol | Nil = nil
  options = {} of Symbol => String | Array(String)

  parser = OptionParser.parse do |parser|
    parser.on("exec", "Execute a command") do
      parser.banner = "USAGE: #{PROGRAM_NAME} exec -- command arguments"
      command = :exec

      parser.unknown_args do |_options, args|
        options[:args] = args
      end
    end

    parser.on("serve", "Start web server at port 8000") do
      parser.banner = "USAGE: #{PROGRAM_NAME} serve"
      command = :serve
      options[:port] = "8000"

      parser.on("-p PORT", "--port=PORT", "Specify a different") do |port|
        options[:port] = port
      end
    end
  end

  case command
  when :exec
    exec_args = options[:args]
    unless exec_args.is_a?(Array(String))
      puts "ERROR: No executable specified"
      puts "USAGE: #{PROGRAM_NAME} exec command arguments"
      exit 1
    end

    process_id = Processes.run_process(exec_args[0], exec_args[1..])
    puts "Started process #{process_id}"
    Fiber.yield
  when :serve
    port = options[:port]
    unless port.is_a?(String) && port.matches?(/^\d+$/)
      puts "ERROR: Invalid port #{port}"
      exit 1
    end

    Web.serve(port: port.to_i)
  else
    puts "ERROR: No command specified"
    puts "USAGE: #{PROGRAM_NAME} command args"
    puts parser
    exit 1
  end
end
