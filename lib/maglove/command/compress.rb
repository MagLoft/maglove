module MagLove
  module Command
    class Compress
      include Commander::Methods
      
      def run
        
        task :theme, theme: "!" do |args, options|
          archive_path("dist/themes/#{options.theme}", "**/*", "#{options.theme}.tar.gz")
          debug("▸ created #{options.theme}.tar.gz")
        end
        
      end
    end
  end
end
