module MagLove
  module Command
    class Util
      include Commander::Methods
      
      def run
        
        task :cache_clear, bucket: "cdn.magloft.com" do |args, options|
          debug("▸ clearing cache for #{options.bucket}.magloft.com")
          system "gsutil -m setmeta -R -h 'Cache-Control:public, max-age=0, no-transform' gs://#{options.bucket}.magloft.com/themes"
        end
        
        task :browser_sync, theme: "!", files: "!", port: "3002", proxy_port: "3001", host: "localhost", start_path: "/", log_level: "silent" do |args, options|
          debug("▸ starting browser-sync")
          job = fork do
            begin
              system "browser-sync start --proxy #{options.host}:#{options.proxy_port} --port #{options.port} --files '#{options.files}' --startPath '#{options.start_path}' --logLevel #{options.log_level} --no-ui"
            rescue Exception => e
              info("▸ shutting down browser sync")
            end
          end
          Process.detach(job)
        end
        
        task :watch, theme: "!", block: "NO" do |args, options|
          info("▸ watching theme #{options.theme}")
          watch_config({
            "compile:coffee" => [theme_path("**/*.{coffee,js}", options.theme), theme_base_path("**/*.{coffee,js}", options.theme)],
            "compile:less" => [theme_path("**/*.{less,css}", options.theme), theme_base_path("**/*.{less,css}", options.theme)],
            "compile:haml" => [theme_path("**/*.{haml,html}", options.theme)],
            "copy:base_images" => theme_base_path("images/**/*.{jpg,jpeg,gif,png,svg}", options.theme),
            "copy:images" => theme_path("images/**/*.{jpg,jpeg,gif,png,svg}", options.theme)
          }, options)
          
          if options.block == "YES"
            while true
              sleep 100
            end
          end
        end

      end
    end
  end
end
