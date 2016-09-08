require "maglove/helper/log_helper"
require "maglove/asset/theme"
module MagLove
  module Commands
    class Base < Thor
      include MagLove::Helper::LogHelper
      include Workspace

      def initialize(args, opts, config)
        namespace = self.class.name.split("::").last.underscore
        command = config[:current_command].name
        Logging.mdc["full_command"] = "#{namespace}:#{command}"
        super
      end

      private

      def magloft_api
        @magloft_api ||= MagLoft::Api.client(options[:token])
      end

      def reset_invocations(*commands)
        reset_command_invocations(self.class, *commands)
      end

      def reset_command_invocations(parent, *commands)
        if commands.length.zero?
          @_invocations[parent] = []
        else
          commands.each do |command|
            @_invocations[parent].delete(command.to_s)
          end
        end
      end
    end

    module OptionValidator
      def self.validate(switch, value)
        case switch
        when "--theme"
          File.directory?("src/themes/#{value}")
        else
          true
        end
      end

      def self.message(switch, value)
        case switch
        when "--theme"
          "The theme '#{value}' does not exist!"
        end
      end
    end
  end
end
