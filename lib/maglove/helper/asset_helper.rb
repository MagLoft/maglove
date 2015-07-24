module MagLove
  module Helper
    module AssetHelper

      def theme_asset(path, theme=nil)
        theme ||= ENV["THEME"]
        if not File.exists?("src/themes/#{theme}/#{path}")
          error! "file '#{path}' not found for theme '#{theme}'"
        end
        MagLove::Asset::Theme.new(path, theme, theme: theme)
      end
  
      def base_theme_asset(path, theme=nil, version=nil)
        theme ||= ENV["THEME"]
        version ||= theme_config("base_version", theme)
        if not File.exists?("src/base/#{version}/#{path}")
          error! "file '#{path}' not found for base-theme '#{version}'"
        end
        MagLove::Asset::BaseTheme.new(path, theme, version)
      end
  
    end
  end
end
