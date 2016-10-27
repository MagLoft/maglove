module Maglove
  module Widgets
    class Youtube < Base
      def identifier
        "youtube"
      end

      def defaults
        {
          youtube_id: "LFYNP40vfmE",
          width: "800",
          height: "600"
        }
      end

      module Helpers
        def youtube_widget(options = {}, &block)
          widget_block(Widgets::Youtube.new(options)) do |widget|
            haml_tag :div, class: "flex-video widescreen", style: style_string(widget.options, :margin, :padding) do
              haml_tag :iframe, src: "https://www.youtube.com/embed/#{widget.options[:youtube_id]}", type: "text/html", style: "max-width: 100%; position: absolute; top: 0px; left: 0px; width: 100%; height: 100%;", allowfullscreen: "", frameborder: "0", webkitallowfullscreen: "", mozallowfullscreen: ""
            end
          end
        end
      end
    end
  end
end
