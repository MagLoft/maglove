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
      
      # template view actions
      templates = theme_config(:templates, self.theme)
      templates.each do |template|
        mount("/#{template}") do |req, res|
          debug("▸ rendering template: #{template}")
          
          # set up dummy variables
          variables = {
            image_url: "http://cdn.magloft.com/themes/medium-dark/images/static/bridge2.jpg",
            title: "Sneaky ways to snag the best seat on the plane",
            html: "<p>In this video series we are going to show you, step by step, what it takes to publish your magazine using MagLoft. As soon as you have signed up for a free account, you have two smaller projects you need to complete. These are:</p><ol><li>Get your content (issues) ready<br/></li><li>Get your publishing information ready</li></ol><p>We have covered getting your content ready in another post, and in this one we will show you exactly how to get your information submitted in order to publish your magazine and get it live in the app stores.</p><h2>PUBLISH YOUR MAGAZINE FOLLOWING THESE EASY STEPS</h2><p>Once logged into MagLoft you need to navigate to the Publishing section from the main (top) menu. From here you will be able to access the steps involved from the left sidebar menu. All of the steps are listed below and we will dive into details for every step. The goal with this tutorial is to show you that you can quickly publish your magazine using MagLoft and that it’s much easier then it actually looks.<br/></p><p>The steps involved are:</p><ol><li>Submit basic information about the magazine you want to publish<br/></li><li>Selecting what type of subscription you want your magazine to offer<br/></li><li>Adding integrations such as push notifications and Google Analytics<br/></li><li>Uploading your images and icons<br/></li><li>Selecting the issue screenshots you want to use in the app stores<br/></li><li>Connecting your developer account<br/></li></ol><p>Now let’s dive right into the video tutorials that will guide you in publishing your magazine!</p><h2>STEP 1 – BASIC MAGAZINE INFORMATION</h2><figure class='tmblr-embed tmblr-full' data-provider='youtube' data-orig-width='459' data-orig-height='344' data-url='https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DeoDyTbEDxMk'><iframe width='540' height='404' src='https://www.youtube.com/embed/eoDyTbEDxMk?feature=oembed' frameborder='0' allowfullscreen=''></iframe></figure><p>There are a few sections you need to fill out in this first step and we will cover each in detail. MagLoft needs this information in order to create, setup and publish your magazine to the App Stores. It’s important you fill out this information and keep it updated. This way you will be able to publish new versions of your magazine in the future without hassle.</p><h2>DESCRIPTION</h2><p>The first sentence of your description should be your “one liner” that describes all the benefits of your magazine. Keep your description easy to read. It’s fine to have a long description if you break it up into sections using headers. You need to make your description compelling and interesting, as this is the second thing readers will see when evaluating to install your app (the first one being the icon).</p><h2>KEYWORDS</h2><p>Make sure you use as many of the 100 characters as possible. Keep your keywords short and don’t use phrases. You should ideally have a main keyword in the title of your magazine, which you don’t need to add again in the keyword section. Remember to add your magazine name/title as the first keyword so people will find it if they search for it.</p><h2>INFO TAB</h2><p>This will be displayed when readers click the info button inside your magazine app. You should include information that is relevant to people that have already installed and opened your magazine like contact information and how the app/subscriptions work.</p><h2>SUPPORT URL9</h2><p>Link to your own support/contact URL. You can use MagLoft’s support desk by default (<a href='https://magloft.zendesk.com'>https://magloft.zendesk.com</a>)</p><h2>MARKETING URL</h2><p>Optional link to any marketing related page you have for your magazine.</p><h2>PRIVACY URL</h2><p>Link to your own privacy policy page. MagLoft provides a standard privacy policy page for your magazine which you can use.</p><h2>CATEGORIES</h2><p>Select the categories that best fit your magazines content. It can sometimes be hard to chose the perfect categories so just chose the closest that match.</p><h2>RATING</h2><p>Apple requires that you rate your content and will score it based on your rating. Offensive ratings won’t be accepted by Apple.</p>",
            original_url: "http://travelinspirations.yahoo.com/post/123527610591/sneaky-ways-to-snag-the-best-seat-on-the-plane",
            tags: "1197772589,Trip Tips,Yahoo Travel,Leah Ginsberg,aeroplane,plane,tips,seats",
            post_type: "text"
          }
          
          # set up toc variables
          variables[:posts] = (0...11).map { variables }
          
          # render template
          variables[:theme] = self.theme
          contents = Hamlet.render(theme_contents("templates/#{template}.haml", self.theme), variables)
          
          # render editor view
          haml_contents = File.read(File.join(Gem.datadir("maglove"), "sdk.haml"))
          res.body = Hamlet.render(haml_contents, theme: self.theme, contents: contents, templates: templates, template: template)
        end
      end
      
      mount("/sdk.js") do |req, res|
        js_contents = File.read(File.join(Gem.datadir("maglove"), "vendor.js"))
        coffee_contents = File.read(File.join(Gem.datadir("maglove"), "sdk.coffee"))
        res.content_type = "text/javascript"
        res.body = [js_contents, CoffeeScript.compile(coffee_contents, bare: true)].join("\n")
      end

      mount("/sdk.css") do |req, res|
        less_contents = File.read(File.join(Gem.datadir("maglove"), "sdk.less"))
        parser  = ::Less::Parser.new(relativeUrls: false)
        res.content_type = "text/css"
        res.body = parser.parse(less_contents).to_css
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
