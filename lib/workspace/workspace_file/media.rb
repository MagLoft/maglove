module Workspace
  class WorkspaceFile
    module Media
      extend ActiveSupport::Concern

      def image?
        ["jpg", "jpeg", "gif", "png"].include?(extension)
      end

      def video?
        ["mp4"].include?(extension)
      end

      def audio?
        ["mp3"].include?(extension)
      end
    end
  end
end
