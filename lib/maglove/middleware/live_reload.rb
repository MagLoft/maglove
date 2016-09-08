require 'filewatcher'
require "faye"
module MagLove
  module Middleware
    class LiveReload
      include Workspace
      attr_reader :app, :options

      def initialize(app, options = {})
        @app = app
        @options = options
        @theme = options[:theme]
        @templates = options[:templates]
      end

      def call(env)
        if env["PATH_INFO"] == @options[:mount]
          request = Rack::Request.new(env)
          @ws = Faye::WebSocket.new(request.env, [], {})
          @ws.onmessage = lambda do |event|
            message = JSON.parse(event.data)
            command = message["command"]
            handle_command(command, message)
          end
          @ws.onclose = ->(event) { clear_watcher! if @watcher }
          @ws.rack_response
        else
          @app.call(env)
        end
      end

      def clear_watcher!
        @ws = nil
        @watcher.stop
        @thread.join
        @watcher = nil
        @thread = nil
      end

      def send_command(command, data = {})
        data[:command] = command
        @ws.send(JSON.dump(data)) if @ws
      end

      def handle_command(command, data = {})
        if command == "init"
          send_command("init", { templates: @templates })
        elsif command == "watch"
          watch
        end
      end

      def watch
        patterns = [
          theme_file("**/*.{haml,html,coffee,js,less,scss,css,yml}"),
          theme_file("images/**/*.{jpg,jpeg,gif,png,svg}"),
          theme_base_file("**/*.{coffee,js,less,scss,css}"),
          theme_base_file("images/**/*.{jpg,jpeg,gif,png,svg}")
        ]
        @watcher = FileWatcher.new(patterns.map(&:to_s))
        @thread = Thread.new(@watcher) do |fw|
          fw.watch do |filename, event|
            if workspace_file(".", filename).exists? and event != :delete
              if filename =~ %r{^src/base/#{theme_config(:base_version)}/.*\.coffee}
                path = "theme.coffee"
              elsif filename =~ %r{^src/base/#{theme_config(:base_version)}/.*\.less}
                path = "theme.less"
              elsif filename =~ %r{^src/base/#{theme_config(:base_version)}/.*\.scss}
                path = "theme.scss"
              elsif filename =~ %r{^src/themes/#{@theme}/.*\.less}
                path = "theme.less"
              elsif filename =~ %r{^src/themes/#{@theme}/.*\.scss}
                path = "theme.scss"
              elsif filename =~ %r{^src/themes/#{@theme}/.*\.coffee}
                path = "theme.coffee"
              else
                path = filename.gsub("src/themes/#{@theme}/", '')
              end
              asset = theme_file(path).asset
              if asset.write!
                case asset.output_type
                when "html"
                  template = path.match(%r{templates/(.*)\.haml})[1]
                  send_command("html", { template: template, contents: asset.contents })
                when "css"
                  send_command("css", { contents: asset.contents })
                when "js"
                  send_command("js", { contents: asset.contents })
                end
              end
            end
          end
        end
      end
    end
  end
end
