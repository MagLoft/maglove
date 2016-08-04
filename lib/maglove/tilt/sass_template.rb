module Sass::Script::Functions  
  def asset(url)
    assert_type url, :String
    Sass::Script::Value::String.new("url(\"#{::Hamloft::Options.defaults[:asset_uri]}/#{url.value}\")")
  end
  declare(:asset, [:url])
end

module MagLove
  module Tilt
    class SassTemplate < ::Tilt::Template
      self.default_mime_type = 'theme/html'

      def prepare
        @options = options.merge({
          style: :nested,
          load_paths: [],
          cache: false,
          cache_location: nil,
          syntax: :sass,
          filesystem_importer: Sass::Importers::Filesystem
        })
      end
    
      def evaluate(scope, locals, &block)
        prepared_data = "@base: \"#{locals[:base_path].sub("src/", "../../")}\";\n#{data}"
        engine = Sass::Engine.new(prepared_data, @options)
        @output ||= engine.render
      end
    end
  end
end
