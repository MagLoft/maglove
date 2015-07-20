module Haml
  module Helpers
    class HorizontalRule < Base

      def identifier
        "horizontal_rule"
      end

      def defaults
        {
          style: 'solid'
        }
      end
    
    end
  end
end