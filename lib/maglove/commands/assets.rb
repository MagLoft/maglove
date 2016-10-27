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

      desc "javascript", "Compile JavaScript"
      def javascript
        info("▸ Compiling JavaScript")
        theme_dir.file("theme.coffee").asset.write!
      end

      desc "stylesheet", "Compile Stylesheet"
      def stylesheet
        info("▸ Compiling Stylesheet")
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
