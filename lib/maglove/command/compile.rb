module MagLove
  module Command
    class Compile
      include Commander::Methods
      
      def run
        
        task :coffee, theme: "!" do |args, options|
          asset = theme_asset("theme.coffee", options.theme)
          debug("▸ created #{asset.logical_path}") if asset.write!
        end
  
        task :less, theme: "!" do |args, options|
          asset = theme_asset("theme.less", options.theme)
          debug("▸ created #{asset.logical_path}") if asset.write!
        end
  
        task :yaml, theme: "!" do |args, options|
          asset = theme_asset("theme.yml", options.theme)
          debug("▸ created #{asset.logical_path}") if asset.write!
        end
  
        task :haml, theme: "!", bucket: "!" do |args, options|
          Hamlet::Options.defaults[:asset_uri] = "http://#{options.bucket}"
          theme_glob("templates/*", options.theme).each do |file|
            asset = theme_asset(file, options.theme)
            debug("▸ created #{asset.logical_path}") if asset.write!
          end
        end

      end
    end
  end
end
