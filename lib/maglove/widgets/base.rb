module Maglove
  module Widgets
    class Base
      include Hamloft::Helpers
      attr_accessor :options

      def identifier
        "base"
      end

      def defaults
        {}
      end

      def initialize(options)
        @options = defaults.merge(options)
      end

      def typeloft_widget_options
        attributes = {
          :class => "_typeloft_widget",
          :"data-widget-identifier" => identifier
        }
        @options.each do |k, v|
          if k == :padding or k == :margin
            [:top, :right, :bottom, :left].each do |dir|
              attributes["data-attribute-#{k}_#{dir}"] = v
            end
          end
          attributes["data-attribute-#{k}"] = v
        end
        attributes
      end
    end
  end
end
