module MagLove
  module Commands
    class Assets < Base
      class_option :theme, type: :string, required: true, validator: OptionValidator

      desc "compile", "Compile all assets"
      def compile
        invoke(:clean)
        invoke(:images)
        invoke(:videos)
        invoke(:javascript)
        invoke(:stylesheet)
        invoke(:yaml)
        invoke(:templates)
        invoke(:blocks)
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
          debug("~> Copying #{file}")
          file.asset(theme: options.theme, base: true).write!
        end
        theme_dir.files("images/**/*.{jpg,png,gif,svg}").each do |file|
          debug("~> Copying #{file}")
          file.asset.write!
        end
      end
      
      desc "videos", "Copy videos"
      def videos
        info("▸ Copying Videos")
        theme_dir.files("videos/**/*.{mp4,webm,ogg}").each do |file|
          debug("~> Copying #{file}")
          file.asset(theme: options.theme).write!
        end
      end
      
      desc "imageoptim", "Optimize images"
      option :percent, type: :numeric, required: true, default: 25
      def imageoptim
        require "image_optim"
        optimizer = ImageOptim.new(nice: 20, pngout: true, optipng: {level: 5}, jpegoptim: {allow_lossy: true, max_quality: 80})
        info("▸ Optimizing Images")
        theme_dir.files("images/**/*.{jpg,png,gif}").each do |file|
          if optimizer.optimizable?(file.to_s)
            new_path = optimizer.optimize_image(file.to_s)
            if !new_path.nil?
              new_file = WorkspaceFile.new("/", new_path.to_s)
              improvement = (file.size.to_f / new_file.size - 1) * 100
              if improvement >= options.percent
                info("~> #{file} optimized #{improvement.to_i}% (#{file.size/1000}kb to #{new_file.size/1000}kb)")
                new_file.move(file)
              else
                debug("~> #{file} (#{improvement.to_i}% < #{options.percent}%)")
              end
            end
          end
        end
      end

      desc "javascript", "Compile JavaScript"
      def javascript
        info("▸ Compiling JavaScript")
        theme_dir.file("theme.coffee").asset.write!
      end

      desc "stylesheet", "Compile Stylesheet"
      def stylesheet
        info("▸ Compiling Stylesheet")
        theme_dir.files("theme.{scss,less}").first.asset(asset_uri: ".").write!
      end

      desc "yaml", "Compile YAML Manifest"
      def yaml
        info("▸ Compiling YAML Manifest")
        theme_dir.file("theme.yml").asset.write!
      end
      
      desc "compress", "Compress Assets for Distribution"
      def compress
        invoke(:javascript)
        invoke(:stylesheet)
        
        info("▸ Compressing JavaScript")
        theme_dir(root: "dist").file("theme.js").minify!
        info("▸ Compressing Stylesheet")
        theme_dir(root: "dist").file("theme.css").minify!
      end

      desc "templates", "Compile HAML Templates"
      def templates
        info("▸ Compiling HAML Templates")
        asset_uri = "file://#{workspace_dir('dist').absolute_path}"
        theme_config(:templates).each do |template|
          debug "~> processing template #{template}"
          template_file = theme_dir.file("templates/#{template}.haml")
          error!("~> Template '#{template}' does not exist!") if template_file.nil?
          contents = template_file.asset(asset_uri: asset_uri).contents
          html_contents = gem_dir.file("export.haml").read_hamloft(theme: options.theme, contents: contents, asset_uri: asset_uri)
          theme_dir(root: "dist").file("templates/#{template}.html").write(html_contents)
        end
      end

      desc "blocks", "Compile HAML Blocks"
      def blocks
        info("▸ Compiling HAML Blocks")
        if theme_dir.dir("blocks").exists?
          asset_uri = "file://#{workspace_dir('dist').absolute_path}"
          theme_dir.dir("blocks").files("**/*.haml").each do |block_file|
            debug "~> processing block #{block_file.basename}"
            contents = block_file.asset(asset_uri: asset_uri).contents
            html_contents = gem_dir.file("export.haml").read_hamloft(theme: options.theme, contents: contents, asset_uri: asset_uri)
            theme_dir(root: "dist").file("blocks/#{block_file.basename}.html").write(html_contents)
          end
        else
          debug "~> no blocks available"
        end
      end
    end
  end
end
