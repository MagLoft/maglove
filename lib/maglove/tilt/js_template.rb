module MagLove
  module Tilt
    class JsTemplate < ::Tilt::Template
      self.default_mime_type = 'application/javascript'

      def prepare
      end

      def evaluate(scope, locals, &block)
        # handle includes
        @data = @data.gsub(%r{^//=\srequire\s(.+)$}) do |match|
          path = Regexp.last_match[1]
          include_path = File.absolute_path(path, File.dirname(file))

          # check if base path exists
          unless File.exist?(include_path)
            include_path = File.absolute_path(path, locals[:base_path])
          end

          if File.exist?(include_path)
            include_template = ::Tilt.new(include_path)
            include_template.render(Object.new, locals)
          else
            raise "Path not found: #{include_path}"
          end
        end

        @output = @data
      end

      def allows_script?
        false
      end
    end
  end
end

Tilt.mappings["js"] = [MagLove::Tilt::JsTemplate]
