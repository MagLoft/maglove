module Maglove
  module Widgets
    class YahooScreen < Base
      def identifier
        "yahoo_screen"
      end

      def defaults
        {
          yahoo_screen_id: "apple-iwatch-iphone-6-135616256",
          width: "800",
          height: "600"
        }
      end

      module Helpers
        def yahoo_screen_widget(options = {}, &block)
          widget_block(Widgets::YahooScreen.new(options)) do |widget|
            haml_tag :div, class: "flex-video widescreen", style: style_string(widget.options, :margin, :padding) do
              haml_tag :iframe, src: "http://screen.yahoo.com/#{widget.options[:yahoo_screen_id]}.html?format=embed", type: "text/html", style: "max-width: 100%; position: absolute; top: 0px; left: 0px; width: 100%; height: 100%;", allowfullscreen: "", frameborder: "0", webkitallowfullscreen: "", mozallowfullscreen: ""
            end
          end
        end
      end
    end
  end
end
