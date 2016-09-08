module Maglove
  module Widgets
    class Container < Base
      def identifier
        "container"
      end

      def defaults
        {
          animate: "none",
          image_source: false,
          image_position: "center_center",
          image_size: "cover",
          parallax_effect: "none",
          background_color: "",
          bg_color: "",
          opacity: "",
          border_radius: "",
          border_width: "",
          border_style: "",
          style: "default",
          padding_top: "",
          padding_right: "",
          padding_bottom: "",
          padding_left: "",
          min_height: "",
          max_height: "",
          margin_top: "",
          margin_right: "",
          margin_bottom: "",
          margin_left: ""
        }
      end

      def container_options
        result = { class: container_classes, style: container_styles }
        result["data-parallax-style"] = @options[:parallax_effect] if !@options[:parallax_effect].empty? and @options[:parallax_effect] != "none"
        result
      end

      def image_options
        { class: "one-container-image", style: image_styles }
      end

      def container_classes
        classes = ["one-container"]
        classes.push("animate #{@options[:animate]}") if @options[:animate] != "none"
        classes.push("container-#{@options[:style]}") unless @options[:style].empty?
        classes.push("container-image-#{@options[:image_size]}") unless @options[:image_size].empty?
        classes.push("container-parallax") if !@options[:parallax_effect].empty? and @options[:parallax_effect] != "none"
        classes.join(" ")
      end

      def container_styles
        style_string @options, :opacity, :border, :opacity, :border_radius, :border_width, :border_style, :margin do |sb|
          sb.add(:background_color, @options[:background_color] == "custom" ? @options[:bg_color] : nil)
          if @options[:background_color] == "overlay"
            sb.add(:background_image, @options[:image_source], "linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url(<%= value %>)")
          else
            sb.add(:background_image, @options[:image_source], "url(<%= value %>)")
          end
          sb.add(:background_position, @options[:image_position], "<%= value.split('_').join(' ') %>")
        end
      end

      def image_styles
        style_string @options, :min_height, :max_height, :padding
      end

      module Helpers
        def container_widget(options = {}, &block)
          widget_block(Widgets::Container.new(options)) do |widget|
            haml_tag :section, widget.container_options do
              haml_tag :div, widget.image_options do
                yield if block
                drop_container
              end
            end
          end
        end
      end
    end
  end
end
