module Maglove
  module Widgets
    class Banner < Base
      def identifier
        "banner"
      end

      def defaults
        {
          style: "dark",
          alignment: "center"
        }
      end
    end
    module Helpers
      def banner_widget(options = {}, &block)
        widget_block(Widgets::Banner.new(options)) do |widget|
          haml_tag :div, class: "banner-outer align-#{widget.options[:alignment]}" do
            haml_tag :div, class: "banner banner-#{widget.options[:style]}" do
              yield if block
              drop_container
            end
          end
        end
      end
    end
  end
end
