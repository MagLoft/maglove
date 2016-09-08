module Maglove
  module Widgets
    class Paragraph < Base
      def identifier
        "paragraph"
      end

      def defaults
        {
          style: "default",
          align: "left",
          size: "md",
          margin_bottom: "1em",
          drop_cap: "",
          drop_cap_color: "#000000"
        }
      end

      module Helpers
        def paragraph_widget(options = {}, contents = nil, &block)
          if options.class.name == "String"
            contents = options
            options = {}
          end
          widget_block(Widgets::Paragraph.new(options)) do |widget|
            haml_tag :div, style: style_string(widget.options, :margin, :padding), class: "paragraph #{widget.options[:style]} align-#{widget.options[:align]} size-#{widget.options[:size]}" do
              unless widget.options[:drop_cap].empty?
                haml_tag :span, class: "__dropcap", style: "color: #{widget.options[:drop_cap_color]};" do
                  haml_concat(widget.options[:drop_cap])
                end
              end

              haml_tag :span, class: "paragraph-content _typeloft_editable _typeloft_widget_autoselect" do
                haml_concat(contents) if contents
                yield if block
              end
            end
          end
        end
      end
    end
  end
end
