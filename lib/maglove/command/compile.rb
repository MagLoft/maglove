module MagLove
  module Command
    class Compile
      include Commander::Methods
      
      def run
        
        task :coffee, theme: "!" do |args, options|
          asset = theme_asset("theme.coffee", options.theme)
          asset.write!
          debug("▸ created #{asset.logical_path}")
        end
  
        task :less, theme: "!" do |args, options|
          asset = theme_asset("theme.less", options.theme)
          asset.write!
          debug("▸ created #{asset.logical_path}")
        end
  
        task :yaml, theme: "!" do |args, options|
          asset = theme_asset("theme.yml", options.theme)
          asset.write!
          debug("▸ created #{asset.logical_path}")
        end
  
        task :haml, theme: "!" do |args, options|
          if options.production
            Haml::Options.defaults[:asset_uri] = "http://cdn.magloft.com/themes/#{options.theme}"
          else
            Haml::Options.defaults[:asset_uri] = "http://localhost:3001/themes/#{options.theme}"
          end
          theme_glob("templates/*", options.theme).each do |file|
            asset = theme_asset(file, options.theme)
            asset.write!
            debug("▸ created #{asset.logical_path}")
          end
        end

      end
    end
  end
end
