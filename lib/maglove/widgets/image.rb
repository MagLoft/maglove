module Maglove
  module Widgets
    class Image < Base
      def identifier
        "image"
      end

      def defaults
        {
          style: "img-responsive",
          align: "center",
          source: false,
          magnify: false,
          margin_bottom: "0",
          tooltip_icon: "bullhorn",
          tooltip_text_alignment: "justify",
          tooltip_text_size: "medium",
          tooltip_position: "top-right",
          tooltip_text: ""
        }
      end

      def image_classes
        classes = ["image-widget"]
        classes.push("align-#{@options[:align]}")
        classes.push("popup-position-#{@options[:tooltip_position]}") if popup?
        classes.join(" ")
      end

      def popup?
        !@options[:tooltip_text].blank?
      end

      module Helpers
        def image_widget(options = {})
          widget_block(Widgets::Image.new(options)) do |widget|
            haml_tag :div, class: widget.image_classes, style: style_string(widget.options, :margin, :padding) do
              if widget.popup?
                haml_tag :i, class: "popup fa fa-lg fa-#{widget.options[:tooltip_icon]}"
                haml_tag :div, class: "popup-box", style: "font-size: #{widget.options[:tooltip_text_size]}, text-align: #{widget.options[:tooltip_text_alignment]};" do
                  haml_concat(widget.options[:tooltip_text])
                end
              end
              haml_tag :img, class: "image #{widget.options[:style]} #{widget.options[:magnify] ? 'magnific-image' : ''}", src: widget.options[:source]
              haml_tag :div, class: "image-drop-target"
            end
          end
        end

        def image_widget_link(options = {})
          widget_block(Widgets::Image.new(options)) do |widget|
            haml_tag :div, class: "image-widget align-#{widget.options[:align]}" do
              link options[:href] do
                haml_tag :img, style: style_string(widget.options, :margin, :padding), class: "image #{widget.options[:style]} #{widget.options[:magnify] ? 'magnific-image' : ''}", src: widget.options[:source]
              end
              haml_tag :div, class: "image-drop-target"
            end
          end
        end
      end
    end
  end
end
