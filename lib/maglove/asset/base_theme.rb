module MagLove
  module Asset
    class BaseTheme < Theme
      attr_reader :version
  
      def initialize(path, theme, version, locals={})
        @version = version
        super(path, theme, locals)
      end
    
      def absolute_path
        File.absolute_path("src/base/#{version}/#{path}")
      end
  
    end
  end
end
