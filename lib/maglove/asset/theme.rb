module MagLove
  module Asset
    class Theme
      include MagLove::Helper::AssetHelper
      include MagLove::Helper::LogHelper
      include MagLove::Helper::ThemeHelper
      attr_reader :mtime, :path, :theme, :valid, :locals, :contents

      OUTPUT_MAPPING = {
        "haml" => "html",
        "twig" => "html",
        "less" => "css",
        "scss" => "css",
        "coffee" => "js",
        "yml" => "json"
      }

      def initialize(path, theme, locals={})
        @path = path
        @theme = theme
        @locals = locals
        @mtime = File.mtime(absolute_path)
        begin
          if ::Tilt[input_type]
            template = ::Tilt.new(absolute_path)
            locals[:base_path] = theme_base_path(nil, theme)
            @contents = template.render(Object.new, locals)
          else
            @contents = File.read(absolute_path)
          end
        rescue Exception => e
          error("▸ #{e.message}")
        end
      end
      
      def input_type
        File.extname(path).gsub("\.", "")
      end
      
      def output_type
        OUTPUT_MAPPING[input_type] or input_type
      end

      def valid?
        !contents.nil?
      end

      def write!
        write_to!(output_path)
      end
      
      def write_to!(path)
        return false if not valid?
        FileUtils.mkdir_p(File.dirname(path))
        
        File.open("#{path}+", 'wb') do |f|
          f.write @contents
        end
        
        # Atomic write
        FileUtils.mv("#{path}+", path)

        # Set mtime correctly
        File.utime(mtime, mtime, path)

        true
      ensure
        # Ensure tmp file gets cleaned up
        FileUtils.rm("#{path}+") if File.exist?("#{path}+")
      end
  
      def absolute_path
        File.absolute_path("src/themes/#{theme}/#{path}")
      end

      def logical_path
        return false if not valid?
        "#{File.dirname(path)}/#{File.basename(path,'.*')}.#{output_type}"
      end

      def output_path
        return false if not valid?
        "dist/themes/#{theme}/#{logical_path}"
      end

    end
  end
end
