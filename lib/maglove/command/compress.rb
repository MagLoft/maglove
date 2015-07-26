module MagLove
  module Command
    class Compress
      include Commander::Methods
      
      def run
        
        task :theme, theme: "!" do |args, options|
          # archive_path("dist/themes/#{options.theme}", "**/*", "#{options.theme}.tar.gz")
          target = "themes/#{options.theme}/#{options.theme}.tar.gz"
          Dir.chdir("dist") do
            tgz = Zlib::GzipWriter.new(File.open(target, "wb"))
            Archive::Tar::Minitar::Output.open(tgz) do |tar|
              Dir["themes/#{options.theme}/**/*"].reject{|file| file == target}.each do |file|
                Archive::Tar::Minitar::pack_file(file, tar)
              end
            end
          end
          
          # Dir.chdir(path) do
          #   tgz = Zlib::GzipWriter.new(File.open(target, 'wb'))
          #   Archive::Tar::Minitar::Output.open(tgz) do |tar|
          #     Dir[pattern].reject{|file| file == target}.each do |file|
          #       Archive::Tar::Minitar::pack_file(file, tar)
          #     end
          #   end
          # end
          
          
          debug("▸ created #{options.theme}.tar.gz")
        end
        
      end
    end
  end
end
