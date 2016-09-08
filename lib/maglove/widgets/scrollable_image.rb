module Maglove
  module Widgets
    class ScrollableImage < Base
      def identifier
        "scrollable_image"
      end

      def defaults
        {
          source: false,
          show_navigation: true,
          height: "400px",
          margin_bottom: "0px"
        }
      end

      module Helpers
        def scrollable_image_widget(options = {})
          widget_block(Widgets::ScrollableImage.new(options)) do |widget|
            haml_tag :div, class: "scrollable-image-container #{widget.options[:show_navigation] ? 'show-navigation' : ''}", style: style_string(widget.options, :margin, :padding, :height) do
              haml_tag :div, class: "scrollable-image-inner" do
                haml_tag :img, class: "scrollable-image", src: widget.options[:source]
              end
              if widget.options[:show_navigation]
                haml_tag :div, class: "scrollable-image-navigator scrollable-image-navigator-left"
                haml_tag :div, class: "scrollable-image-navigator scrollable-image-navigator-right"
              end
            end
          end
        end
      end
    end
  end
end
