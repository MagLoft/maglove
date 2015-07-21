module MagLove
  module Asset
    class Theme
      include MagLove::Helper::AssetHelper
      include MagLove::Helper::LogHelper
      
      attr_accessor :path, :asset, :theme, :valid, :absolute_path

      def initialize(path, theme)
        self.path = path
        self.theme = theme
        begin
          self.asset = get_sprockets.find_asset("#{absolute_path}")
        rescue Exception => e
          error("▸ #{e.message}")
          self.asset = nil
        end
      end
  
      def get_sprockets
        sprockets(theme)
      end

      def valid?
        !self.asset.nil?
      end

      def write!
        return false if not valid?
        FileUtils.mkdir_p(File.dirname(output_path))
        asset.write_to(output_path)
        true
      end
  
      def absolute_path
        File.absolute_path("src/themes/#{theme}/#{path}")
      end

      def logical_path
        return false if not valid?
        self.asset.logical_path
      end


      def output_path
        return false if not valid?
        "dist/themes/#{theme}/#{asset.logical_path}"
      end

    end
  end
end
