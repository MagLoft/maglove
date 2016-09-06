module Workspace
  class WorkspaceDir
    module Archive
      extend ActiveSupport::Concern

      def compress_zip(target_file)
        target_file.delete!
        require "zip"
        Zip::File.open(target_file.to_s, 'w') do |zipfile|
          Dir["#{self}/**/**"].each do |file|
            zipfile.add(file.sub("#{self}/", ''), file)
          end
        end
        self
      end
    end
  end
end
