module Workspace
  class WorkspaceFile
    module Parse
      extend ActiveSupport::Concern
    
      def read_json
        JSON.parse(read)
      end
    
      def read_yaml
        Psych.load_file(to_s)
      end
    
      def read_haml(options)
        require "haml"
        engine = Haml::Engine.new(read)
        engine.render(Object.new, options)
      end
    end
  end
end
