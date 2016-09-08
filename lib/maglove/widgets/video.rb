module Maglove
  module Widgets
    class Video < Base
      def identifier
        "video"
      end

      def defaults
        {
          width: "640",
          height: "360",
          preload: "auto",
          style: "default",
          source: false,
          poster: false,
          autoplay: false,
          controls: true,
          loop: false,
          margin_bottom: "0"
        }
      end

      module Helpers
        def video_widget(options = {})
          widget_block(Widgets::Video.new(options)) do |widget|
            haml_tag :div, class: "video-widget player-style-#{widget.options[:style]}" do
              haml_tag :video, controls: true, poster: widget.options[:poster], style: "width: 100%" do
                haml_tag :source, src: widget.options[:source].to_s, type: "video/mp4"
              end
            end
          end
        end
      end
    end
  end
end
