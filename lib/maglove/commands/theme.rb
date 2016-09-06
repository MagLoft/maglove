module MagLove
  module Commands
    class Theme < Base
      desc "server", "Launch Development Server"
      option :host, type: :string, default: "127.0.0.1"
      option :proxy_port, type: :string, default: "3001"
      option :port, type: :string, default: "3000"
      option :theme, type: :string, required: true, validator: OptionValidator
      def server
        invoke(Assets, :compile, [], { theme: options.theme })
        invoke(Fonts, :compile, [], {})
        info("▸ starting server for theme '#{options.theme}' on '#{options.host}:#{options.port}'")
        require 'maglove/server'
        MagLove::Server.start(options.port, options.theme, theme_config(:templates))
      end

      desc "export", "Export to HTML"
      option :out, type: :string, aliases: :o
      option :theme, type: :string, required: true, validator: OptionValidator
      def export
        invoke(Assets, :compile, [], theme: options.theme, asset_uri: ".")
        target_dir = workspace_dir(options.out || "export/#{options.theme}").reset!
        theme_dir(root: "dist").copy(target_dir.dir("themes/#{options.theme}"))
        workspace_dir("dist/fonts").copy(target_dir.dir("fonts"))
        templates = theme_config(:templates)
        templates.each do |template|
          debug "▸ processing template #{template}"
          template_file = theme_dir.files("templates/#{template}.{html,twig,haml}").first
          error!("▸ Template '#{template}' does not exist!") if template_file.nil?
          html_contents = gem_dir.file("export.haml").read_hamloft(theme: options.theme, contents: template_file.asset.contents, templates: templates, template: template)
          target_dir.file("#{template}.html").write(html_contents)
        end
        info("▸ Exported theme '#{options.theme}' to #{target_dir.absolute_path}")
      end

      desc "push", "Push Theme to MagLoft"
      option :token, type: :string, required: true
      option :theme, type: :string, required: true, validator: OptionValidator
      def push
        info("▸ Pushing theme '#{options.theme}' to MagLoft")

        # initialize api
        require 'magloft'
        magloft = MagLoft::Api.client(options[:token])
        theme_identifier = theme_config(:identifier)
        error!("Theme '#{theme_identifier}' not found") unless theme_identifier
        theme = magloft.typeloft_themes.find_by_identifier(theme_identifier)
        if theme.nil?
          info("▸ To create a new theme, run: maglove theme:create --theme '#{theme_identifier}' --name '#{theme_identifier.titlecase}'")
          error!("Theme '#{theme_identifier}' was not yet created.")
        end

        # fetch templates
        templates = theme_config(:templates)
        templates.each do |template_identifier|
          debug "▸ synchronizing template #{template_identifier}"

          # Render template
          template_file = theme_dir.files("templates/#{template_identifier}.{html,twig,haml}").first
          next unless !template_file.nil? and template_file.exists?
          asset = template_file.asset
          template = theme.typeloft_templates.find_by_identifier(template_identifier)
          template = theme.typeloft_templates.new(identifier: template_identifier, title: template_identifier.titlecase) if template.nil?
          template.contents = asset.contents if template.contents != asset.contents
          template.save
        end

        info("▸ Successfully pushed theme: #{templates.count} templates")
      end

      desc "create", "Create a new Theme on MagLoft"
      option :token, type: :string, required: true
      option :name, type: :string, required: true
      option :description, type: :string, required: false
      option :theme, type: :string, required: true
      def create
        info("▸ Creating new theme '#{options.theme}'")
        require 'magloft'
        magloft = MagLoft::Api.client(options[:token])
        theme = magloft.typeloft_themes.find_by_identifier(options.theme)
        error!("This theme already exists") unless theme.nil?
        magloft.typeloft_themes.create(identifier: options.theme, name: options.name, description: options.description)
        info("▸ Theme successfully created!")
      end

      desc "delete", "Delete an existing Theme on MagLoft"
      option :token, type: :string, required: true
      option :theme, type: :string, required: true
      def delete
        info("▸ Deleting theme '#{options.theme}'")
        require 'magloft'
        magloft = MagLoft::Api.client(options[:token])
        theme = magloft.typeloft_themes.find_by_identifier(options.theme)
        error!("Could not find a theme with identifier '#{options.theme}'") if theme.nil?
        theme.destroy
        info("▸ Theme successfully deleted!")
      end

      desc "list", "Delete an existing Theme on MagLoft"
      option :token, type: :string, required: true
      def list
        info("▸ Listing themes")
        require 'magloft'
        magloft = MagLoft::Api.client(options[:token])
        magloft.typeloft_themes.all.each do |theme|
          info("~> #{theme.identifier} (NAME: #{theme.name}, ACTIVE: #{theme.active ? 'YES' : 'NO'})")
        end
      end
    end
  end
end
