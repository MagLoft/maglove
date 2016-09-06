require 'rack'
require 'maglove/middleware/live_reload'

module MagLove  
  class Server
    include Workspace
    attr_reader :app, :options
    
    def self.start(port, theme, templates)
      app = Rack::Builder.new do
        use MagLove::Middleware::LiveReload, mount: "/maglove", theme: theme, templates: templates
        use Rack::Static, urls: ["/fonts", "/themes"], root: "dist"
        run MagLove::Server.new(theme: theme, templates: templates)
      end
      # self.webrick.mount "/issue", Hpub::IssueServlet
      # self.webrick.mount "/manifest.json", Hpub::ManifestServlet
      Rack::Server.start(app: app, Port: port, server: :puma)
    end
    
    def initialize(options)
      @options = options
    end
    
    def call(env)
      template = env["PATH_INFO"].sub("/", "")
      if env["PATH_INFO"] == "/maglove.js"
        [200, {'Content-Type' => 'text/javascript'}, [gem_dir.file("maglove.js").read]]
      elsif env["PATH_INFO"] == "/maglove.css"
        [200, {'Content-Type' => 'text/css'}, [gem_dir.file("maglove.css").read]]
      elsif @options[:templates].include?(template)
        [200, {'Content-Type' => 'text/html'}, [process(template)]]
      else
        [200, {'Content-Type' => 'text/html'}, [gem_dir.file("index.haml").read_hamloft(@options)]]
      end
    end
    
    def process(template)
      css_contents = theme_dir(root: "dist").file("theme.css").read
      js_contents = theme_dir(root: "dist").file("theme.js").read
      Hamloft::Options.defaults[:asset_uri] = "."
      file = theme_dir.files("templates/#{template}.{html,twig,haml}").first
      gem_dir.file("maglove.haml").read_hamloft(theme: @options[:theme], contents: file.asset.contents, css_contents: css_contents, js_contents: js_contents, template: template)
    end
    
    # def setup(theme)
    #   # create widget hash maps
    #   @widget_stamps = {}
    #   Dir["widgets/*.rb"].each { |file| @widget_stamps[file] = File.mtime(file).to_i }
    #   
    #   # template view actions
    #   @options[:templates].each do |template|
    #     mount("/#{template}") do |req, res|
    #       Dir["widgets/*.rb"].each do |file|
    #         stamp = File.mtime(file).to_i
    #         if @widget_stamps[file] and @widget_stamps[file] < stamp
    #           @widget_stamps[file] = stamp
    #           debug("▸ reloading widget: #{file}")
    #           load(file)
    #         end
    #       end
    #     end
    #   end
    # end
  end
end
