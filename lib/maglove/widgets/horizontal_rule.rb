module Maglove
  module Widgets
    class HorizontalRule < Base
      def identifier
        "horizontal_rule"
      end

      def defaults
        {
          style: 'solid',
          color: 'dark',
          max_height: 'inherit'
        }
      end

      module Helpers
        def horizontal_rule_widget(options = {})
          widget_block(Widgets::HorizontalRule.new(options)) do |widget|
            haml_tag :hr, style: "max-height: #{widget.options[:max_height]}", class: "#{widget.options[:style]} #{widget.options[:color]}"
          end
        end
      end
    end
  end
end
