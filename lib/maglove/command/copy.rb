module MagLove
  module Command
    class Copy
      include Commander::Methods
      
      def run

        task :base_images, theme: "!", pattern: "images/**/*.{jpg,png,gif,svg}" do |args, options|
          pattern = options.pattern.gsub(theme_base_path("", options.theme), "")
          theme_base_glob(pattern, options.theme).each do |file|
            asset = base_theme_asset(file, options.theme)
            debug("▸ created #{asset.logical_path}") if asset.write!
          end
        end

        task :images, theme: "!", pattern: "images/**/*.{jpg,png,gif,svg}" do |args, options|
          pattern = options.pattern.gsub(theme_path("", options.theme), "")
          theme_glob(pattern, options.theme).each do |file|
            asset = theme_asset(file, options.theme)
            debug("▸ created #{asset.logical_path}") if asset.write!
          end
        end  
  
        task :thumbs, theme: "!", pattern: "thumbs/**/*.{jpg,png,gif,svg}" do |args, options|
          pattern = options.pattern.gsub(theme_path("", options.theme), "")
          theme_glob(pattern, options.theme).each do |file|
            asset = theme_asset(file, options.theme)
            debug("▸ created #{asset.logical_path}") if asset.write!
          end
        end

      end
    end
  end
end
