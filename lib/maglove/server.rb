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
          view = View.editor
          engine = Haml::Engine.new(view)
          debug("▸ rendering template: #{template}")
          res.body = engine.render(Object.new, theme: self.theme, contents: theme_dist_contents("templates/#{template}.html", self.theme), templates: templates, template: template)
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
