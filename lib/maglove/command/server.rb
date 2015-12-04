module MagLove
  module Command
    class Server
      include Commander::Methods
      
      def run

        task :run, theme: "!" do |args, options|
          info("▸ starting server for theme '#{options.theme}'")
          MagLove::Server.new(options.theme).run!
        end
        
        task :hpub, port: "8080" do |args, options|
          info("▸ starting hpub server at http://127.0.0.1:#{options.port}/manifest.json")
          MagLove::Hpub::Server.new(options.port).run!
        end
        
      end
    end
  end
end
