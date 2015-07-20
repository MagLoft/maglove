module Sprockets
  class HamlTemplate < Tilt::Template
    self.default_mime_type = 'theme/html'
        
    def prepare
      
    end

    def evaluate(scope, locals, &block)
      @output ||= Haml::Engine.new(data, {remove_whitespace: true}).render(self, {})
    end

    def allows_script?
      false
    end
  end
  
  register_engine '.haml', HamlTemplate
  register_mime_type("theme/html", ".html")
end
