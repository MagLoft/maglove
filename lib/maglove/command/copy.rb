module MagLove
  module Command
    class Copy
      include Commander::Methods
      
      def run

        task :base_images, theme: "!" do |args, options|
          theme_base_glob("images/**/*.{jpg,png,gif,svg}", options.theme).each do |file|
            asset = base_theme_asset(file, options.theme)
            asset.write!
            debug("▸ created #{asset.logical_path}")
          end
        end

        task :images, theme: "!" do |args, options|
          theme_glob("images/**/*.{jpg,png,gif,svg}", options.theme).each do |file|
            asset = theme_asset(file, options.theme)
            asset.write!
            debug("▸ created #{asset.logical_path}")
          end
        end  
  
        task :thumbs, theme: "!" do |args, options|
          theme_glob("thumbs/**/*.{jpg,png,gif,svg}", options.theme).each do |file|
            asset = theme_asset(file, options.theme)
            asset.write!
            debug("▸ created #{asset.logical_path}")
          end
        end

      end
    end
  end
end
