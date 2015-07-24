module MagLove
  module Command
    class Theme
      include Commander::Methods
      
      def run

        task :compile, theme: ENV["THEME"], sync: "NO", bucket: "localhost:3002" do |args, options|
          info("▸ compiling theme #{options.theme}")
          invoke_tasks(["core:validate", "core:clean", "compile:coffee", "compile:less", "compile:yaml", "compile:haml", "copy:base_images", "copy:images", "copy:thumbs", "compress:theme"], options)
          
          if options.sync == "YES"
            error!("▸ SYNC error: please specify a bucket to use (cdn.magloft.com, test-cdn.magloft.com)") if options.bucket == "localhost:3001"
            invoke_task("sync:cdn", options)
          end
          
        end
        
        task :"compile-all", sync: "NO" do |args, options|
          themes = Dir.chdir("src/themes") { Dir.glob("*") }
          themes.each do |theme|  
            options.theme = theme
            invoke_task("theme:compile", options)
          end
        end
        
        task :dev, theme: ENV["THEME"] do |args, options|
          options.production = false
          invoke_task("theme:compile", options)
          invoke_task("font:compile", options)
          options.block = "NO"
          invoke_task("util:watch", options)
          
          # browser sync
          options.files = "dist/themes/#{options.theme}/*.css, dist/themes/#{options.theme}/*.js, dist/themes/#{options.theme}/templates/*.html, dist/themes/#{options.theme}/images/**/*"
          options.start_path = theme_config(:templates, options.theme).first
          invoke_task("util:browser_sync", options)
          
          invoke_task("server:run", options)
        end

      end
    end
  end
end
