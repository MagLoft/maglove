module MagLove
  module Tilt
    class LessTemplate < ::Tilt::Template
      self.default_mime_type = 'theme/html'

      def prepare
        @parser = ::Less::Parser.new(options.merge(filename: eval_file, line: line, relativeUrls: false))
      end

      def evaluate(scope, locals, &block)
        prepared_data = "@base: \"#{locals[:base_path].sub('src/', '../../')}\";\n#{data}"
        @engine = @parser.parse(prepared_data)
        @output ||= @engine.to_css(options)
      end
    end
  end
end

Tilt.mappings["less"] = [MagLove::Tilt::LessTemplate]
