module Maglove
  module Widgets
    class Slider < Base
      def identifier
        "slider"
      end

      def defaults
        {
          slides: "3",
          height: "auto",
          margin_bottom: "0px",
          background_color: "#EEEEEE",
          autoplay: "true",
          autoplay_timeout: "3000"
        }
      end

      def slider_options
        data = { autoplay: @options[:autoplay], autoplay_timeout: @options[:autoplay_timeout] }
        { class: "owl-carousel", style: slider_styles, data: data }
      end

      def slider_styles
        style_string @options, :margin, :height, :background_color do |sb|
          sb.add(:min_height, "200px")
          sb.add(:overflow, "hidden")
        end
      end

      module Helpers
        def slider_widget(options = {}, &block)
          widget_block(Widgets::Slider.new(options)) do |widget|
            haml_tag :div, widget.slider_options do
              yield if block
            end
          end
        end

        def slider_item(options = {}, &block)
          haml_tag :div, class: "item" do
            yield if block
            drop_container
          end
        end
      end
    end
  end
end
