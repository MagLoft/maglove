module MagLove
  module Asset
    class Theme
      attr_accessor :path, :asset, :theme, :valid, :absolute_path

      def initialize(path, theme)
        self.path = path
        self.theme = theme    
        self.asset = sprockets.find_asset("#{absolute_path}")
      end
  
      def sprockets
        Commander::Methods.sprockets(theme)
      end

      def valid?
        !self.asset.nil?
      end

      def write!
        return false if not valid?
        FileUtils.mkdir_p(File.dirname(output_path))
        asset.write_to(output_path)
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
