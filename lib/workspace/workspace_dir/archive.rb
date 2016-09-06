module Workspace
  class WorkspaceDir
    module Archive
      extend ActiveSupport::Concern
    
      def compress_zip(target_file)
        target_file.delete!
        require "zip"
        Zip::File.open(target_file.to_s, 'w') do |zipfile|
          Dir["#{to_s}/**/**"].each do |file|
            zipfile.add(file.sub("#{to_s}/",''), file)
          end
        end
        self
      end
    end
  end
end
