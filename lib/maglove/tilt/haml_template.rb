module MagLove
  module Tilt
    class HamlTemplate < ::Tilt::Template
      self.default_mime_type = 'theme/html'
        
      def prepare
      
      end

      def evaluate(scope, locals, &block)
        @output ||= Hamlet::Engine.new(data, {remove_whitespace: true}).render(scope, locals)
      end

      def allows_script?
        false
      end
    end

  end
end
