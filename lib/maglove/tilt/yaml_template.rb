module MagLove
  module Tilt
    class YamlTemplate < ::Tilt::Template
      self.default_mime_type = 'application/json'

      def prepare
      end

      def evaluate(scope, locals, &block)
        @output ||= YAML.load(data).to_json
      end

      def allows_script?
        false
      end
    end
  end
end

Tilt.mappings["yml"] = [MagLove::Tilt::YamlTemplate]
