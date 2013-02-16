require 'io/console'

module Qcp
  class CommandError < RuntimeError
  end

  class App
    def run(qcp_filename, args, stdout = $stdout, stderr = $stderr, stdin = $stdin)
      @qcp_filename = qcp_filename
      @out = stdout
      @err = stderr
      @in = stdin

      if args.length == 0
        usage
        return 1
      end

      begin
        handle_command(args)
      rescue Qcp::ServerError, CommandError => e
        @err.puts "Error: #{e.message}"
        return 1
      end

      return 0
    end

  private
    def handle_command(args)
      command = command_from_arg(args[0])

      if command.nil?
        raise CommandError, "Unrecognized command: #{args[0]}.\n\n#{$usage}"
      end

      args.shift
      send(command, args) 
    end

    def command_from_arg(arg)
      commands = {
        /\A(help|-h|--help)\z/i => :help,
        /\A(version|ver|-v|--version)\z/i => :version,
        /\A(init|i)\z/i => :init,
        /\A(copy|cp|c)\z/i => :copy,
        /\A(paste|p)\z/i => :paste
      }

      commands.each { |pattern, command|
        return command if arg =~ pattern
      }

      return nil
    end

    def help(args)
      if args.length > 1
        raise CommandError, "Invalid arguments.\n\n#{$usage}"
      end

      if args.empty?
        usage
        return
      end

      command = command_from_arg(args[0])

      if command.nil?
        raise CommandError, "No help for unrecognized command: #{args[0]}.\n\n#{$usage}"
      end

      help = {
        :help => $help_usage,
        :init => $init_usage,
        :copy => $copy_usage,
        :paste => $paste_usage
      }

      usage = help[command]
      if usage.nil?
        raise CommandError, "No help available for command: #{args[0]}."
      end

      @out.puts usage
    end

    def version(args)
      @out.puts "qcp client version #{$version}"

      begin
        client = load_client
        @out.puts "qcp server version #{client.version}"
      rescue
        # Ignore any errors when trying to get the server version.
      end
    end

    def init(args)
      if args.length != 1
        raise CommandError, "Invalid arguments.\n\n#{$init_usage}"
      end

      server = args.first

      config = load_config
      client = Qcp::Client.new(server)

      if !client.configured?
        @out.puts 'Server is not initialized. Initializing now.'
        master = prompt_password('Master password')
        token = client.register(master)
        config.server = server
        config.token = token
        config.save!
        @out.puts 'Client registered.'
      else
        if config.token && config.server
          if config.server == server
            @out.puts "Client is already registered with #{server}."
          else
            @out.puts "Client is currently registered with #{config.server}."
            confirm = prompt_confirm("Register with #{server} instead? ")
            if confirm
              register_client(server, client, config)
            end
          end
        else
          @out.puts 'Server is already initialized. Registering new client.'
          register_client(server, client, config)
        end
      end
    end

    def copy(args)
      client = load_client
      client.copy(args.join(' '))
      @out.puts 'OK'
    end

    def paste(args)
      client = load_client
      @out.puts client.paste
    end

    def usage
      @out.puts "qcp client version #{$version}"
      @out.puts
      @out.puts $usage
    end

  private
    def load_config
      Qcp::Config.new(File.join(Dir.home, '.qcp'))
    end

    def load_client
      config = load_config
      if !config.server || !config.token
        raise CommandError, "Run 'qcp init' first."
      end

      Qcp::Client.new(config.server, config.token)
    end

    def register_client(server, client, config)
      @out.print 'Master password: '
      master = input_password
      token = client.register(master)
      config.server = server
      config.token = token
      config.save!
      @out.puts 'Client registered.'
    end

    def prompt_password(prompt = 'Password')
      begin
        @out.print "#{prompt}: "
        password = input_password()

        if password.empty?
          @out.puts 'Password cannot be blank.'
          raise
        end

        @out.print "#{prompt} (verify): "
        verify = input_password()

        if verify != password
          @out.puts 'Passwords do not match.'
          raise
        end
      rescue
        retry
      end

      return password
    end

    def input_password
      input = proc { |stdin|
        raw = stdin.gets
        return nil if raw.nil?

        password = raw.strip
        @out.puts

        return password
      }

      begin
        @in.noecho { |stdin|
          input.call stdin
        }
      rescue Errno::EBADF
        # This can happen when stdin refers to a file or pipe.
        # In this case, we ignore 'no echo' and do normal input.
        input.call @in
      end
    end

    def prompt_confirm(prompt)
      begin
        @out.print prompt

        confirm = @in.gets.strip

        if confirm =~ /\Ay/i
          return true
        elsif confirm =~ /\An/i
          return false
        end
      rescue
        retry
      end
    end
  end
end
