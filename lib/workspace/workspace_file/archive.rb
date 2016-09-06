module Workspace
  class WorkspaceFile
    module Archive
      extend ActiveSupport::Concern

      def extract(target_dir)
        target_dir.create
        if extension == "zip"
          extract_zip(target_dir)
        elsif extension == "gz"
          extract_gz(target_dir)
        end
        self
      end

      private

      def extract_zip(target_dir)
        require "zip"
        Zip::File.open(to_s) do |archive|
          archive.each do |entry|
            entry.extract(File.join(target_dir.to_s, entry.name))
          end
        end
      end

      def extract_gz(target_dir)
        require 'rubygems/package'
        workspace_dir = target_dir.root_dir
        archive = Gem::Package::TarReader.new(Zlib::GzipReader.open(to_s))
        archive.rewind
        archive.each do |entry|
          if entry.directory?
            archive_dir = workspace_dir.dir(entry.full_name)
            archive_dir.create
          elsif entry.file?
            archive_file = workspace_dir.file(entry.full_name)
            archive_file.write(entry.read)
          end
        end
        archive.close
      end
    end
  end
end
