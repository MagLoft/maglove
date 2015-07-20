module MagLove
  module Command
    class Core
      include Commander::Methods
      
      def run

        task :validate, theme: "!" do |args, options|
          error! "no theme specified" if !options.theme
          error! "theme #{options.theme} does not exist" if !File.directory?("src/themes/#{options.theme}")
          debug("theme: #{options.theme}")
          debug("environment: #{options.production ? 'production' : 'development'}")
        end
        
        task :clean, theme: "!" do |args, options|
          theme_clean(options.theme)
          debug("▸ cleaned up theme directory")
        end

      end
    end
  end
end
