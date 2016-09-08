module MagLove
  module Commands
    class Theme < Base
      desc "server", "Launch Development Server"
      option :port, type: :string, default: "4000"
      option :theme, type: :string, required: true, validator: OptionValidator
      def server
        invoke(Assets, :compile, [], { theme: options.theme })
        invoke(Fonts, :compile, [], {})
        info("▸ starting server for theme '#{options.theme}' on '127.0.0.1:#{options.port}'")
        require 'maglove/server'
        MagLove::Server.start(options.port, options.theme, theme_config(:templates))
      end

      desc "export", "Export to HTML"
      option :theme, type: :string, required: true, validator: OptionValidator
      def export
        info("▸ Exporting Theme '#{options.theme}'")
        invoke(Assets, :compile, [], theme: options.theme, asset_uri: ".")
        Hamloft::Options.defaults[:asset_uri] = "."
        templates = theme_config(:templates)
        templates.each do |template|
          debug "▸ processing template #{template}"
          template_file = theme_dir.files("templates/#{template}.{html,twig,haml}").first
          error!("▸ Template '#{template}' does not exist!") if template_file.nil?
          html_contents = gem_dir.file("export.haml").read_hamloft(theme: options.theme, contents: template_file.asset.contents, templates: templates, template: template)
          workspace_dir("dist").file("#{options.theme}-#{template}.html").write(html_contents)
        end
      end

      desc "thumbnails", "Create page thumbnails"
      option :theme, type: :string, required: true, validator: OptionValidator
      def thumbnails
        invoke(:export)
        info("▸ Generating Thumbnails for Theme '#{options.theme}'")
        html_files = workspace_dir("dist").files("#{options.theme}-*.html")
        urls = html_files.map { |f| "file://#{f.absolute_path}" }
        require "powersnap"
        powersnap = Powersnap.new(urls)
        powersnap.generate(dir: theme_dir(root: "dist").dir("thumbnails").reset!.to_s, width: 768, height: 1024, pattern: "{basename}.png", zoom: 1.0, page: false)
        theme_dir(root: "dist").dir("thumbnails").files("*.png").each do |image_file|
          template_name = image_file.basename.sub(/^#{options.theme}-/, "")
          image_file.rename!("#{template_name}.png")
        end
      end

      desc "push", "Push Theme to MagLoft"
      option :token, type: :string, required: true
      option :theme, type: :string, required: true, validator: OptionValidator
      option :thumbnails, type: :boolean, default: false
      def push
        info("▸ Pushing theme '#{options.theme}' to MagLoft")

        # invoke asset compilation
        invoke(Assets, :compile, [], { theme: options.theme })

        # validate theme
        theme_identifier = theme_config(:identifier)
        error!("Theme '#{theme_identifier}' not found") unless theme_identifier
        theme = magloft_api.typeloft_themes.find_by_identifier(theme_identifier)
        if theme.nil?
          info("▸ To create a new theme, run: maglove theme:create --theme '#{theme_identifier}'")
          error!("Theme '#{theme_identifier}' was not yet created.")
        end

        # update theme
        info("▸ Synchronizing Metadata")
        theme.base_version = theme_config(:base_version)
        theme.name = theme_config(:name)
        theme.description = theme_config(:description)
        theme.save

        # upload blocks
        theme_blocks = theme.typeloft_blocks.all
        theme_blocks_map = Hash[theme_blocks.map { |block| [block.identifier, block] }]
        block_files = theme_dir.chdir("blocks").files("**/*.haml")
        block_files.each do |block_file|
          block_identifier = block_file.slug
          if (block = theme_blocks_map[block_identifier])
            block.name = block_file.basename.titlecase
            block.contents = block_file.read
            if block.changed?
              info "▸ Updating Block '#{block_identifier}'"
              block.save
            end
          else
            info "▸ Creating Block '#{block_identifier}'"
            theme.typeloft_blocks.create(identifier: block_identifier, name: block_file.basename.titlecase, contents: block_file.read)
          end
        end

        # upload images
        info("▸ Synchronizing Images")
        theme_images = theme.typeloft_images.all
        theme_images_map = Hash[theme_images.map { |image| [image.remote_file, image] }]
        theme_dir(root: "dist").files("images/**/*.{jpg,png,gif,svg}").each do |image_file|
          remote_file = "themes/#{options.theme}/#{image_file.relative_path}"
          if (existing_image = theme_images_map[remote_file])
            if image_file.md5 != existing_image.md5
              info("▸ Updating Image '#{remote_file}'")
              existing_image.md5 = image_file.md5
              existing_image.save
              existing_image.upload(image_file.to_s)
            end
          else
            info("▸ Creating Image '#{remote_file}'")
            new_image = theme.typeloft_images.create(remote_file: remote_file, title: image_file.basename.titlecase, md5: image_file.md5)
            new_image.upload(image_file.to_s)
          end
        end

        # upload css/js
        info("▸ Synchronizing JavaScript and Stylesheet")
        theme.upload_stylesheet(theme_dir(root: "dist").file("theme.css").to_s)
        theme.upload_javascript(theme_dir(root: "dist").file("theme.js").to_s)

        # upload templates
        info("▸ Synchronizing Templates")
        theme_templates = theme.typeloft_templates.all
        theme_templates_map = Hash[theme_templates.map { |template| [template.identifier, template] }]
        templates = theme_config(:templates)
        templates.each_with_index do |template_identifier, position|
          template_file = theme_dir.files("templates/#{template_identifier}.{html,twig,haml}").first
          next unless !template_file.nil? and template_file.exists?
          if (template = theme_templates_map[template_identifier])
            template.title = template_identifier.titlecase
            template.contents = template_file.read
            template.position = position
            if template.changed?
              info "▸ Updating Template '#{template_identifier}'"
              template.save
            end
          else
            info "▸ Creating Template '#{template_identifier}'"
            theme.typeloft_templates.create(identifier: template_identifier, title: template_identifier.titlecase, contents: template_file.read, position: position)
          end
        end

        # update thumbnails
        if options.thumbnails
          info("▸ Synchronizing Thumbnails")
          invoke(:thumbnails, [], { theme: options.theme })
          theme.typeloft_templates.all.each do |template|
            thumbnail_file = theme_dir(root: "dist").dir("thumbnails").file("#{template.identifier}.png")
            if thumbnail_file.exists?
              info("~> Uploading Thumbnail for '#{template.identifier}'")
              template.upload_thumbnail(thumbnail_file.to_s)
            end
          end
        end

        info("▸ Successfully Pushed Theme")
      end

      desc "create", "Create a new Theme on MagLoft"
      option :token, type: :string, required: true
      option :theme, type: :string, required: true, validator: OptionValidator
      def create
        info("▸ Creating new theme '#{options.theme}'")

        error!("Missing yaml config 'name'") unless theme_config(:name)
        error!("Missing yaml config 'base_version'") unless theme_config(:base_version)
        theme = magloft_api.typeloft_themes.find_by_identifier(options.theme)
        error!("This theme already exists") unless theme.nil?
        magloft_api.typeloft_themes.create(identifier: options.theme, name: theme_config(:name), description: theme_config(:description), base_version: theme_config(:base_version))
        info("▸ Theme successfully created!")
      end

      desc "delete", "Delete an existing Theme on MagLoft"
      option :token, type: :string, required: true
      option :theme, type: :string, required: true
      def delete
        info("▸ Deleting theme '#{options.theme}'")
        theme = magloft_api.typeloft_themes.find_by_identifier(options.theme)
        error!("Could not find a theme with identifier '#{options.theme}'") if theme.nil?
        theme.destroy
        info("▸ Theme successfully deleted!")
      end

      desc "list", "Delete an existing Theme on MagLoft"
      option :token, type: :string, required: true
      def list
        info("▸ Listing themes")
        magloft_api.typeloft_themes.all.each do |theme|
          info("~> #{theme.identifier} (NAME: #{theme.name}, ACTIVE: #{theme.active ? 'YES' : 'NO'})")
        end
      end
    end
  end
end
