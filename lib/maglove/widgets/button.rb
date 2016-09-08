module Maglove
  module Widgets
    class Button < Base
      def identifier
        "button"
      end

      def defaults
        {
          style: "primary",
          type: "btn-fit",
          size: "btn-lg",
          media: false
        }
      end

      def button_classes
        classes = ["btn", "btn-#{@options[:style]}", @options[:size], @options[:type], "_typeloft_editable"]
        classes.push("btn-media") if @options[:media]
        classes.join(" ")
      end

      def button_options
        result = { class: button_classes, href: (@options[:href] or "#"), style: style_string(@options, :margin, :padding) }
        result["data-media"] = @options[:media] if @options[:media] and !@options[:media].empty?
        result
      end

      module Helpers
        def button_widget(options = {}, contents = nil, &block)
          if options.class.name == "String"
            contents = options
            options = {}
          end
          widget_block(Widgets::Button.new(options)) do |widget|
            haml_tag :a, widget.button_options do
              if widget.options[:media] and !widget.options[:media].blank?
                haml_tag :video do
                  haml_tag :source, { src: widget.options[:media], type: "video/mp4" }
                end
              end
              haml_concat(contents) if contents
              yield if block
            end
          end
        end
      end
    end
  end
end
