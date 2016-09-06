module MagLove
  module Template
    class Tumblr < Hamloft::Template
      def chunks
        self.doc.children
      end

      def container(&block)
        haml.container_widget(padding_left: "0em", padding_right: "0em", &block)
      end

      def process_chunk(chunk)
        case chunk.name
        when "text"
          haml.paragraph_widget({ margin_left: "2em", margin_right: "2em" }, chunk.text)
        when "p"
          haml.paragraph_widget({ margin_left: "2em", margin_right: "2em" }, chunk.text)
        when "ol", "ul"
          haml.paragraph_widget({ margin_left: "2em", margin_right: "2em" }) do
            haml.haml_tag chunk.name, class: "user-list" do
              chunk.children.each do |child|
                haml.haml_tag :li do
                  haml.haml_concat child.text
                end
              end
            end
          end
        when "h1", "h2", "h3", "h4", "h5"
          haml.heading_widget({ type: chunk.name, margin_left: "2em", margin_right: "2em", margin_bottom: "1em" }, chunk.text)
        when "a"
          if chunk.css("img").length > 0
            haml.image_widget_link(href: chunk.attribute("href").to_s, source: chunk.css("img").first.attribute("src").to_s)
          else
            haml.paragraph_widget({ margin_left: "2em", margin_right: "2em" }, chunk.text) do
              haml.link(chunk.attribute("href").to_s)
            end
          end
        when "figure"
          case chunk.children.first.name
          when "img"
            haml.image_widget(source: chunk.children.first.attribute("src").to_s, margin_bottom: "1em")
          when "iframe"
            iframe_url = chunk.children.first.attribute("src").value
            if (match = iframe_url.match("screen\.yahoo\.com\/([a-z0-9\-]+)\.html"))
              haml.yahoo_screen_widget(yahoo_screen_id: match[1], margin_bottom: "1em")
            elsif (match = iframe_url.match("www\.youtube\.com\/.*\/([a-zA-Z0-9]+)"))
              haml.youtube_widget(youtube_id: match[1], margin_bottom: "1em")
            else
              puts "-- unhandled iframe: #{iframe_url}"
            end
          else
            puts "-- unhandled figure: #{chunk.children.first.name}"
          end
        when "div"
          if chunk.attribute("class").to_s == "sponlogo"
            haml.container_widget background_color: "white", padding_left: "1em", padding_right: "1em", padding_bottom: "0.5em", padding_top: "1em" do
              haml.columns_widget columns: "3x9" do |row|
                haml.column row do
                  process_chunk(chunk.children[0])
                end
                haml.column row do
                  haml.paragraph_widget({ align: "right" }, chunk.children[1].text)
                end
              end
            end
          else
            haml.container_widget do
              chunk.children.each do |child_chunk|
                process_chunk(child_chunk)
              end
            end
          end
        else
          puts "-- unhandled chunk: #{chunk.name}"
        end
      end
    end
  end
end
