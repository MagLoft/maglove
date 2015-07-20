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
          
          begin

            theme_watch("**/*.haml", options.theme) do |filename|
              invoke_task("compile:haml", options)
            end
            
            theme_base_watch("**/*.coffee", options.theme) do |filename|
              invoke_task("compile:coffee", options)
            end
            
            theme_watch("**/*.coffee", options.theme) do |filename|
              invoke_task("compile:coffee", options)
            end
            
            theme_base_watch("**/*.less", options.theme) do |filename|
              invoke_task("compile:less", options)
            end
            
            theme_watch("**/*.less", options.theme) do |filename|
              invoke_task("compile:less", options)
            end
          
            if options.block == "YES"
              info("▸ press [ctrl+c] to exit")
              while sleep(100) do nil end
            end
          rescue Exception => e
            puts "losed^"
          end
        end

      end
    end
  end
end
