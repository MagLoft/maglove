module MagLove
  class Server
    include Commander::Methods
    attr_accessor :port, :root, :theme, :webrick
    
    def initialize(theme, port=3001)
      self.theme = theme
      self.port = port
      self.root = "dist/"
      
      # create server
      self.webrick = WEBrick::HTTPServer.new(
        Port: self.port,
        DocumentRoot: self.root,
        Logger: WEBrick::Log.new("/dev/null"),
        AccessLog: []
      )
      
      # prepare controller actions
      templates = theme_config(:templates, self.theme)
      templates.each do |template|
        mount("/#{template}") do |req, res|
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
          res.body = Hamlet.render(View.editor, theme: self.theme, contents: contents, templates: templates, template: template)
        end
      end
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
