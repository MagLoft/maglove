module MagLove
  class Server
    include Commander::Methods
    attr_accessor :port, :root, :theme, :webrick
    
    def initialize(theme, port=3001)
      self.theme = theme
      self.port = port
      self.root = "dist/"
      @widget_stamps = {}
      
      # create server
      self.webrick = WEBrick::HTTPServer.new(
        Port: self.port,
        DocumentRoot: self.root,
        Logger: WEBrick::Log.new("/dev/null"),
        AccessLog: []
      )
      
      # create widget hash maps
      Dir["widgets/*.rb"].each do |file|
        @widget_stamps[file] = File.mtime(file).to_i
      end
      
      # template view actions
      templates = theme_config(:templates, self.theme)
      templates.each do |template|
        mount("/#{template}") do |req, res|
          
          Dir["widgets/*.rb"].each do |file|
            stamp = File.mtime(file).to_i
            if @widget_stamps[file] and @widget_stamps[file] < stamp
              @widget_stamps[file] = stamp
              debug("▸ reloading widget: #{file}")
              load(file)
            end
          end
          
          debug("▸ rendering template: #{template}")
          
          # Prepare variables
          variables = {}
          variables_yaml = theme_contents("templates/#{template}.yml", self.theme)
          variables = YAML.load(variables_yaml).with_indifferent_access if variables_yaml
          variables[:theme] = self.theme
          
          # Render template
          template_file = theme_glob("templates/#{template}.{html,twig,haml}", self.theme).first
          if !template_file.nil?
            asset = MagLove::Asset::Theme.new(template_file, self.theme, variables)
            contents = asset.contents
          else
            contents = "<p style='text-align: center; margin-top: 12px;'>ERROR: Template '#{template}' not found!</p>"
          end
          
          # render editor view
          if File.exists?(theme_path("theme.haml", self.theme))
            layout_path = theme_path("theme.haml", self.theme)
          else
            layout_path = File.join(Gem.datadir("maglove"), "sdk.haml")
          end
          haml_contents = File.read(layout_path)
          res.body = Hamloft.render(haml_contents, theme: self.theme, contents: contents, templates: templates, template: template)
        end
      end
      
      self.webrick.mount "/issue", Hpub::IssueServlet
      self.webrick.mount "/manifest.json", Hpub::ManifestServlet
    end
    
    def mount_template(path, view, options={})
      mount(path) do |req, res|
        engine = Haml::Engine.new(parse_view(view))
        res.body = engine.render(Object.new, options)
      end
    end
    
    def mount(path, &block)
      self.webrick.mount_proc(path, &block)
    end
    
    def run!
      trap 'INT' do 
        self.webrick.shutdown
      end
      self.webrick.start
    end
    
  end
end
