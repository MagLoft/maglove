require "tilt"
require "sass"
require "less"
require "maglove/tilt/twig_template"
require "maglove/tilt/haml_template"
require "maglove/tilt/less_template"
require "maglove/tilt/scss_template"
require "maglove/tilt/coffee_template"
require "maglove/tilt/js_template"
require "maglove/tilt/yaml_template"

module MagLove
  module Asset
    class Theme
      include Workspace
      include MagLove::Helper::LogHelper
      attr_reader :mtime, :path, :valid, :contents, :options

      OUTPUT_MAPPING = {
        "haml" => "html",
        "twig" => "html",
        "less" => "css",
        "scss" => "css",
        "coffee" => "js",
        "yml" => "json"
      }

      def initialize(path, options = {})
        @path = path
        @options = options
        @mtime = File.mtime(absolute_path)
        begin
          if ::Tilt[input_type]
            template = ::Tilt.new(absolute_path)
            @contents = template.render(Object.new, @options.merge(base_path: theme_base_dir.to_s))
          else
            @contents = File.read(absolute_path)
          end
        rescue StandardError => e
          error("▸ #{e.message}")
        end
      end

      def input_type
        File.extname(path).delete("\.")
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
        return false unless valid?
        FileUtils.mkdir_p(File.dirname(path))
        File.open("#{path}+", 'wb') { |f| f.write @contents }
        FileUtils.mv("#{path}+", path)
        File.utime(mtime, mtime, path)
        true
      ensure
        FileUtils.rm("#{path}+") if File.exist?("#{path}+")
      end

      def absolute_path
        if @options[:base]
          File.absolute_path("src/base/#{theme_config(:base_version)}/#{path}")
        else
          File.absolute_path("src/themes/#{@options[:theme]}/#{path}")
        end
      end

      def logical_path
        return false unless valid?
        dirname = File.dirname(path)
        if dirname == "/"
          "#{File.basename(path, '.*')}.#{output_type}"
        else
          "#{dirname}/#{File.basename(path, '.*')}.#{output_type}"
        end
      end

      def output_path
        return false unless valid?
        "dist/themes/#{@options[:theme]}/#{logical_path}"
      end
    end
  end
end
