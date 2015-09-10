module MagLove
  module Helper
    module ThemeHelper

      @@config = {}

      def theme_clean(theme=nil)
        FileUtils.rm_rf(theme_dist_path(nil, theme))
        FileUtils.mkdir_p(theme_dist_path(nil, theme))
      end

      def theme_config(key=nil, theme)
        if not @@config[theme]
          @@config[theme] = YAML.load(theme_contents("theme.yml", theme))
        end
        if key.nil?
          @@config[theme]
        else
          @@config[theme][key.to_s]
        end
      end

      def theme_glob(pattern, theme)
        glob = []
        Dir.chdir(theme_path(nil, theme)) do
          glob = Dir.glob(pattern)
        end
        glob
      end
  
      def theme_path(path=nil, theme)
        path.nil? ? "src/themes/#{theme}" : "src/themes/#{theme}/#{path}"
      end
  
      def theme_dist_path(path=nil, theme)
        path.nil? ? "dist/themes/#{theme}" : "dist/themes/#{theme}/#{path}"
      end
  
      def theme_contents(path, theme)
        if File.exists?(theme_path(path, theme))
          File.read(theme_path(path, theme))
        else
          nil
        end
      end
      
      def theme_write_contents(path, contents, theme)
        File.open(theme_path(path, theme), "w") {|f| f.write(contents) }
      end
    
      def theme_dist_contents(path, theme)
        File.read(theme_dist_path(path, theme))
      end
  
      def theme_base_glob(pattern, theme)
        glob = []
        Dir.chdir(theme_base_path(nil, theme)) do
          glob = Dir.glob(pattern)
        end
        glob
      end
  
      def theme_base_path(path=nil, theme)
        path.nil? ? "src/base/#{theme_config(:base_version, theme)}" : "src/base/#{theme_config(:base_version, theme)}/#{path}"
      end
  
      def theme_dist_glob(pattern, theme)
        Dir.glob("dist/themes/#{theme}/#{pattern}")
      end
    
      def theme_watch(pattern, theme, &block)
        watch(theme_path(pattern, theme), &block)
      end
    
      def theme_base_watch(pattern, theme, &block)
        watch(theme_base_path(pattern, theme), &block)
      end
    
      def watch_config(config, options)
        config.each do |task, pattern|
          watch(pattern) do |filename, event|
            begin
              invoke_task(task, options.__merge(pattern: filename))
            rescue Exception => e
              error(e.message)
            end
          end
        end
      end
    
      def watch(pattern, &block)
        watcher = FileWatcher.new(pattern)
        Thread.new(watcher) do |fw|
          fw.watch do |filename, event|
            if !File.directory?(filename) and event != :delete
              info("▸ file changed: #{filename}")
              block.call(filename, event)
            end
          end
        end
      end

    end
  end
end
