require 'tilt'
require 'yaml'

module MagLove
  module Tilt
    class TwigTemplate < ::Tilt::Template
      self.default_mime_type = 'theme/html'

      def initialize_engine
        install_php_dependencies
      end

      def prepare; end

      def evaluate(scope, locals, &block)
        return @output unless @output.nil?
        yaml_file     = Tempfile.new(['context-', '.yml'])
        yaml_data     = locals.merge(scope.kind_of?(Hash) ? scope : {}).stringify_keys
        begin
          File.open(yaml_file.path, 'w') { |file| file.write(yaml_data.to_yaml) }
          @output = `php #{binary_path} render -d '#{File.dirname(file)}' -y '#{yaml_file.path}' '#{File.basename(file)}'`
        rescue
          raise
        ensure
          yaml_file.close
          yaml_file.unlink
        end
      end

      private

      def install_php_dependencies
        unless File.exist?(binary_path)
          require 'open-uri'
          File.open(binary_path, "wb") do |saved_file|
            open("https://github.com/MagLoft/twigster/raw/master/twigster.phar", "rb") do |read_file|
              saved_file.write(read_file.read)
            end
          end
        end
      end

      def binary_path
        File.join(Gem.datadir("maglove"), "twigster.phar")
      end
    end
  end
end

Tilt.mappings["twig"] = [MagLove::Tilt::TwigTemplate]
