require "pry"

module MagLove
  module Hpub
    
    class IssueServlet < WEBrick::HTTPServlet::AbstractServlet
      include Commander::Methods
      
      def do_GET(req, res)
        theme = File.basename(req.path, ".*")
        config = theme_config(nil, theme)
        working_dir = Dir.mktmpdir
        data_dir = Gem.datadir("maglove")
        
        # Create book.json
        book_json = {
          "hpub" => 1,
          "title" => config["name"],
          "author" => ["MagLove"],
          "creator" => ["MagLove"],
          "date" => Time.now.strftime("%Y-%m-%d %H:%M:%S UTC"),
          "url" => "book://www.magloft.com",
          "orientation" => "both",
          "-baker-background" => "#FFFFFF",
          "-baker-index-height" => 240,
          "-baker-media-autoplay" => false,
          "-baker-rendering" => "three-cards",
          "-baker-page-numbers-color" => "#333",
          "-baker-vertical-bounce" => true,
          "-baker-page-turn-tap" => true,
          "-baker-start-at-page" => 1,
          "-baker-max-zoom-level" => 2.0,
          "zoomable" => true,
          "contents" => config["templates"].map{|t| "#{t}.html"}
        }
        File.open("#{working_dir}/book.json", "w"){|f| f.write(book_json.to_json) }
        
        # Copy assets
        FileUtils.cp_r("dist/fonts", "#{working_dir}/fonts")
        FileUtils.cp_r("dist/themes/#{theme}/thumbs", "#{working_dir}/thumbs")
        FileUtils.cp("dist/themes/#{theme}/thumbs/#{config["templates"][0]}.png", "#{working_dir}/cover.png")
        FileUtils.mkdir_p("#{working_dir}/stylesheets")
        FileUtils.cp("#{data_dir}/hpub/index.css", "#{working_dir}/stylesheets/index.css")
        FileUtils.mkdir_p("#{working_dir}/themes")
        FileUtils.cp_r("dist/themes/#{theme}", "#{working_dir}/themes/#{theme}")
        
        # Create index html
        index_contents = File.read("#{data_dir}/hpub/index.haml")
        engine = Haml::Engine.new(index_contents)
        index_html = engine.render(Object.new, config)
        File.open("#{working_dir}/index.html", "w"){|f| f.write(index_html) }
        
        # Compile themes
        Hamloft::Options.defaults[:asset_uri] = "."
        theme_glob("templates/*.{html,haml,twig}", theme).each do |file|
          # compile template
          template = File.basename(file, ".*")
          locals = {}
          locals_contents = theme_contents(file.sub(/\.[^.]+\z/, ".yml"), theme)
          if locals_contents
            locals = YAML.load(locals_contents).with_indifferent_access
          end
          asset = theme_asset(file, theme, locals)
          
          # wrap in page
          page_contents = File.read("#{data_dir}/hpub/page.haml")
          engine = Haml::Engine.new(page_contents)
          page_html = engine.render(Object.new, {template: template, theme: theme, contents: compile_html(asset.contents)})
          
          # Write to file
          File.open("#{working_dir}/#{template}.html", "w"){|f| f.write(page_html) }
        end
        
        # Delete zip file
        zip_path = "#{working_dir}/themes/#{theme}/#{theme}.tar.gz"
        FileUtils.rm_f(zip_path) if File.exists?(zip_path)
        
        # Create zip archive
        FileUtils.rm_f("dist/#{theme}.hpub") if File.exists?("dist/#{theme}.hpub")
        Zip::File.open("dist/#{theme}.hpub", Zip::File::CREATE) do |zipfile|
          Dir[File.join(working_dir, '**', '**')].each do |file|
            zipfile.add(file.sub("#{working_dir}/", ''), file)
          end
        end
        
        # respond
        res.status = 200
        res['Content-Type'] = "application/zip"
        res.body = File.read("dist/#{theme}.hpub")
      end
      
      private
      
        def compile_html(contents)
      		doc = Nokogiri::HTML.fragment(contents.force_encoding("UTF-8"))
    
          # unwrap widgets
          doc.css("._typeloft_widget").each do |node|

            # remove unneeded attributes
            node.attributes.each do |key, attribute|
               node.attributes[key].remove if key != "style" and key != "class"
            end
      
            # clean up classes
            if not node.attributes["class"].nil?
              classList = node.attributes["class"].value.split(" ")
              classList.reject!{|cls| ["_typeloft_widget", "ui-resizable", "_typeloft_widget_selected", "_typeloft_widget_hover"].include?(cls)}
              node.attributes["class"].value = classList.join(" ")
            end
          end
    
          # remove scripts
          doc.css('script').remove()
    
          # unwrap drop containers
          doc.css("._typeloft_widget_drop_container").each do |node|
            node.children.each do |child|
              node.parent << child
            end
            node.remove
          end
    
          # remove data-typeloft-slug attributes
          doc.xpath( './/*[@data-typeloft-slug]|*[@data-typeloft-slug]' ).each do |node|
            node.attributes["data-typeloft-slug"].remove
          end
    
          # remove contenteditable attributes
          doc.xpath( './/*[@contenteditable]|*[@contenteditable]' ).each do |node|
            node.attributes["contenteditable"].remove
          end
    
          # remove widget containers
          doc.css("._typeloft_widget_container").remove()
    
          # remove typeloft classes
          doc.xpath(".//*[@*[contains(., '_typeloft_')]]").each do |node|
            classes = node[:class].split(' ').select{|cls| !cls.include?('_typeloft_')}
            node[:class] = classes.join(' ')
          end
    
          # convert iframe https links to http
          doc.search('iframe[src*="https://"]').each do |node|
            src = node[:src].sub('https://', 'http://')
            node[:src] = src
          end
    
          # fetch html          
          clean_html_chars(doc.to_s)
        end
        
        def clean_html_chars(characters)
          ["\u1680", "\u180E", "\u2000", "\u2001", "\u2002", "\u2003", "\u2004", "\u2005", "\u2006", "\u2007", "\u2008", "\u2009", "\u200A", "\u200B", "\u202F", "\u205F", "\u3000", "\uFEFF"].each do |char|
            characters = characters.force_encoding("UTF-8").gsub(char, "&nbsp&nbsp")
          end
          characters.force_encoding("BINARY").gsub(0xC2.chr+0xA0.chr+" ","&nbsp;&nbsp;").gsub(0xC2.chr+0xA0.chr,"&nbsp;")
        end
    end
    
    class Server
      include Commander::Methods
      attr_accessor :port, :webrick
    
      def initialize(port=8080)
        self.port = port
      
        # create server
        self.webrick = WEBrick::HTTPServer.new(
          Port: self.port,
          DocumentRoot: "dist/",
          Logger: WEBrick::Log.new("/dev/null"),
          AccessLog: []
        )
        
        # Manifest JSON
        mount("/manifest.json") do |req, res|
          res.content_type = "application/json"
          res.body = build_manifest_json
        end
        
        self.webrick.mount "/issue", IssueServlet
      end
      
      def build_manifest_json
        manifest = []
        Dir.glob("dist/themes/*") do |dir|
          theme = File.basename(dir)
          config = theme_config(nil, theme)
          manifest.push({
            name: theme,
            title: config["name"],
            product_id: nil,
            info: config["description"],
            date: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
            url: "http://127.0.0.1:#{self.port}/issue/#{theme}.hpub",
            cover: "http://127.0.0.1:#{self.port}/themes/#{theme}/thumbs/#{config["templates"][0]}.png"
          })
        end
        manifest.to_json
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
end
