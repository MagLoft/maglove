module MagLove
  module Commands
    class Assets < Base
      class_option :theme, type: :string, required: true, validator: OptionValidator

      desc "compile", "Compile all assets"
      def compile
        invoke(:clean)
        invoke(:images)
        invoke(:javascript)
        invoke(:stylesheet)
        invoke(:yaml)
        invoke(:templates)
        invoke(:thumbnails)
        invoke(:zip)
      end

      desc "clean", "Clean theme dist directory"
      def clean
        info("▸ Cleaning up Theme Directory")
        theme_dir(root: "dist").reset!
      end
            
      desc "images", "Copy images"
      def images
        info("▸ Copying Images")
        workspace_dir("src/base/#{theme_config(:base_version)}").files("images/**/*.{jpg,png,gif,svg}").each do |file|
          debug("~> Copying #{file.to_s}")
          file.asset(theme: options.theme, base: true).write!
        end
        theme_dir.files("images/**/*.{jpg,png,gif,svg}").each do |file|
          debug("~> Copying #{file.to_s}")
          file.asset.write!
        end
      end
      
      desc "javascript", "Compile JavaScript"
      def javascript
        info("▸ Compiling JavaScript")
        theme_dir.file("theme.coffee").asset.write!
      end
      
      desc "stylesheet", "Compile Stylesheet"
      def stylesheet
        info("▸ Compiling stylesheet")
        theme_dir.files("theme.{scss,less}").first.asset.write!
      end
      
      desc "yaml", "Compile YAML Manifest"
      def yaml
        info("▸ Compiling YAML Manifest")
        theme_dir.file("theme.yml").asset.write!
      end
      
      desc "templates", "Compile HAML Templates"
      def templates
        info("▸ Compiling HAML Templates")
        Hamloft::Options.defaults[:asset_uri] = options.asset_uri
        theme_dir.files("templates/*.{html,haml,twig}").each do |file|
          debug("~> compiling #{file.to_s}")
          file.asset.write!
        end
      end
      
      desc "thumbnails", "Copy Thumbnail Images"
      def thumbnails
        info("▸ Copying Thumbnails")
        theme_dir.files("thumbs/**/*.{jpg,png,gif,svg}").each do |file|
          debug("~> copying #{file.to_s}")
          file.asset.write!
        end
      end
      
      desc "zip", "Archive theme"
      def zip
        info("▸ Creating #{options.theme}.tar.gz")
        require "archive/tar/minitar"
        target = "themes/#{options.theme}/#{options.theme}.tar.gz"
        Dir.chdir("dist") do
          tgz = Zlib::GzipWriter.new(File.open(target, "wb"))
          Archive::Tar::Minitar::Output.open(tgz) do |tar|
            Dir["themes/#{options.theme}/**/*"].reject{|file| file == target}.each do |file|
              if !(/^themes\/#{options.theme}\/(images|thumbs|templates)/.match(file))
                Archive::Tar::Minitar::pack_file(file, tar)
              end
            end
          end
        end
      end
    end
  end
end
