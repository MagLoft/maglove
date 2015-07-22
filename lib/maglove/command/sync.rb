module MagLove
  module Command
    class Sync
      include Commander::Methods
      
      def run

        task :cdn, theme: "!", bucket: "test-cdn.magloft.com" do |args, options|
          error! "theme '#{options.theme}' does not exist. Did you run theme:compile yet?" if !options.theme or !File.directory?("dist/themes/#{options.theme}")
          info("▸ synchronizing #{options.theme} to #{options.bucket}")
          system "gsutil -m rsync -d -r dist/themes/#{options.theme} gs://#{options.bucket}/themes/#{options.theme}"
        end

      end
    end
  end
end
