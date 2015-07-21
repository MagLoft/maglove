module MagLove
  module Helper
    module CommandHelper
  
      def task(action, option_config={}, &block)
        command "#{library}-#{action}" do |c|
          required_options = []
          c.syntax = "maglove #{library} #{action}"
          c.summary = "#{library} #{action} command"
          option_config.each do |key, value|
            if value == "!"
              required_options.push(key)
              c.option "--#{key} STRING", String, "[required]"
            else
              c.option "--#{key} STRING", String, "[default: #{value}]"
            end
          end
          c.task_action do |args, options|
            Logging.mdc["command"] = "#{library}-#{action}"
            required_options.each do |required_option|
              if !options.__hash__[required_option.to_sym]
                error!("missing required option '#{required_option}'")
              end
            end
            options.default(option_config)
            block.call(args, options)
          end
        end
      end
    
      def library
        self.class.name.split("::").last.underscore
      end
    
      def invoke_tasks(command_names, *args)
        command_names.each do |command_name|
          invoke_task(command_name, *args)
        end
      end
    
      def invoke_task(command_name, *args)
        command_name = command_name.gsub(":", "-")
        if args.length == 0
          command_args = []
          command_options = Commander::Command::Options.new
        elsif args.length == 1
          if args[0].class == Array
            command_args = args[0]
            command_options = Commander::Command::Options.new
          else
            command_args = []
            command_options = args[0]
          end
        elsif args.length == 2
          command_args = args[0]
          command_options = Commander::Command::Options.new
        else
          error!("invalid arguments specified for invoke_task '#{command_name}'")        
        end
        command = Commander::Runner.instance.commands[command_name]
        error!("cannot invoke command '#{command_name}': command not found") if command.nil?
        command.invoke(command_args, command_options)
      end

    end
  end
end
