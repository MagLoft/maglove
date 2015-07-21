module MagLove
  module Asset
    class BaseTheme < Theme
      attr_accessor :version
  
      def initialize(path, theme, version)
        self.version = version
        super(path, theme)
      end
    
      def get_sprockets
        base_sprockets(version)
      end
    
      def absolute_path
        File.absolute_path("src/base/#{version}/#{path}")
      end
  
    end
  end
end
