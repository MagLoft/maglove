module MagLove
  module Command
    class Sync
      include Commander::Methods
      
      def run

        task :cdn, theme: "!" do |args, options|
          error! "theme '#{options.theme}' does not exist. Did you run theme:compile yet?" if !options.theme or !File.directory?("dist/themes/#{options.theme}")
          bucket = options.production ? "cdn.magloft.com" : "test-cdn.magloft.com"
          info("▸ synchronizing theme '' to bucket '#{bucket}'")
          puts "gsutil -m rsync -d -r dist/themes/#{options.theme} gs://cdn.magloft.com/themes/#{options.theme}"
        end

      end
    end
  end
end
