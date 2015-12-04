module MagLove
  module Command
    class Server
      include Commander::Methods
      
      def run

        task :run, theme: "!" do |args, options|
          info("▸ starting server for theme '#{options.theme}'")
          MagLove::Server.new(options.theme).run!
        end
        
      end
    end
  end
end
