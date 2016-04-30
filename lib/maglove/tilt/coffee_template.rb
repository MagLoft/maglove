module MagLove
  module Tilt
    class CoffeeTemplate < ::Tilt::Template
      self.default_mime_type = 'application/javascript'

      def self.engine_initialized?
        defined? ::CoffeeScript
      end

      def initialize_engine
        require_template_library 'coffee_script'
      end

      def prepare
        options[:bare] = true
      end

      def evaluate(scope, locals, &block)
        @output = CoffeeScript.compile(@data, options)
        
        # handle includes
        @output.gsub(/^include\("([^"]+)"\);$/) do |match|
          path = Regexp.last_match[1]
          path = "#{path}.coffee" if File.extname(path).empty?
          include_path = File.absolute_path(path, File.dirname(file))
          
          # check if base path exists
          if not File.exists?(include_path)
            include_path = File.absolute_path(path, locals[:base_path])
          end
          
          if File.exists?(include_path)
            include_template = ::Tilt.new(include_path)
            include_template.render(Object.new, locals)
          else
            raise "Path not found: #{include_path}"
          end
        end
        
      end

      def allows_script?
        false
      end
    end
  end
end
