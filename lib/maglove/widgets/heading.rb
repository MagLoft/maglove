module Maglove
  module Widgets
    class Heading < Base
      def identifier
        "heading"
      end

      def defaults
        {
          type: "h1",
          style: "default",
          align: "left",
          margin_bottom: "1em"
        }
      end

      module Helpers
        def heading_widget(options = {}, contents = nil, &block)
          if options.class.name == "String"
            contents = options
            options = {}
          end
          widget_block(Widgets::Heading.new(options)) do |widget|
            haml_tag :header, class: "#{widget.options[:style]} align-#{widget.options[:align]}", style: style_string(widget.options, :margin, :padding) do
              haml_tag widget.options[:type], class: "_typeloft_editable _typeloft_widget_autoselect" do
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
