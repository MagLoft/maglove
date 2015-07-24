module MagLove
  module Tilt
    class LessTemplate < ::Tilt::Template
      self.default_mime_type = 'theme/html'

      def prepare
        parser  = ::Less::Parser.new(options.merge :filename => eval_file, :line => line, :relativeUrls => false)
        @engine = parser.parse(data)
      end
    
      def evaluate(scope, locals, &block)
        @output ||= @engine.to_css(options)
      end
    
    end
  end
end
