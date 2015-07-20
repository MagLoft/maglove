module Haml
  module Helpers
    class Image < Base

      def identifier
        "image"
      end

      def defaults
        {
          style: "img-responsive",
          source: false,
          magnify: false,
          margin_bottom: "0"
        }
      end
    
    end
  end
end