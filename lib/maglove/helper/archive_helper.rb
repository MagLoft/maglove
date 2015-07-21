module MagLove
  module Helper
    module ArchiveHelper
  
      def archive_path(path, pattern, target, theme=nil)
        theme ||= ENV["THEME"]
        Dir.chdir(path) do
          tgz = Zlib::GzipWriter.new(File.open(target, 'wb'))
          Archive::Tar::Minitar::Output.open(tgz) do |tar|
            Dir[pattern].reject{|file| file == target}.each do |file|
              Archive::Tar::Minitar::pack_file(file, tar)
            end
          end
        end
      end
      
    end
  end
end
