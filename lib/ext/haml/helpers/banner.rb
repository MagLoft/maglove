module Haml
  module Helpers
    class Banner < Base

      def identifier
        "banner"
      end

      def defaults
        {
          style: "dark",
          alignment: "center"
        }
      end
    
    end
  end
end