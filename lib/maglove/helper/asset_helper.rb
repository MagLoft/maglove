module MagLove
  module Helper
    module AssetHelper
      @@sprockets = {}

      def theme_asset(path, theme=nil)
        theme ||= ENV["THEME"]
        if not File.exists?("src/themes/#{theme}/#{path}")
          error! "file '#{path}' not found for theme '#{theme}'"
        end
        MagLove::Asset::Theme.new(path, theme)
      end
  
      def base_theme_asset(path, theme=nil, version=nil)
        theme ||= ENV["THEME"]
        version ||= theme_config("base_version", theme)
        if not File.exists?("src/base/#{version}/#{path}")
          error! "file '#{path}' not found for base-theme '#{version}'"
        end
        MagLove::Asset::BaseTheme.new(path, theme, version)
      end

      def sprockets(theme=nil)
        theme ||= ENV["THEME"]
        if @@sprockets[theme].nil?
          @@sprockets[theme] = Sprockets::Environment.new(".") do |env| 
            env.logger = Logging::Logger.new("Sprockets")
          end
          @@sprockets[theme].append_path("src/themes/#{theme}")
          @@sprockets[theme].append_path("src/base")
        end
        @@sprockets[theme]
      end
  
      def base_sprockets(version)
        if @@sprockets[version].nil?
          @@sprockets[version] = Sprockets::Environment.new(".") do |env|
            env.logger = Logging::Logger.new("Sprockets")
          end
          @@sprockets[version].append_path("src/base/#{version}")
        end
        @@sprockets[version]
      end
  
    end
  end
end
