module Haml
  module Helpers
    class Youtube < Base

      def identifier
        "youtube"
      end

      def defaults
        {
          youtube_id: "LFYNP40vfmE",
          width: "800",
          height: "600"
        }
      end
    
    end
  end
end