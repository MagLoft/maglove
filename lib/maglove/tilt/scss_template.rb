require 'sass-css-importer'
module Sass::Script::Functions
  def asset(url)
    assert_type url, :String
    Sass::Script::Value::String.new("url(\"#{asset_uri}/#{url.value}\")")
  end

  def asset_uri
    options[:locals][:asset_uri] || Hamloft.asset_uri
  end

  def asset_data(url)
    assert_type url, :String
    theme = options[:locals][:theme]
    asset_path = "dist/themes/#{theme}/#{url.value}"
    asset_contents = File.open(asset_path).read
    base64_string = Base64.strict_encode64(asset_contents)
    extension = File.extname(url.value)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(extension).to_s
    data_uri = "data:#{mime_type};base64,#{base64_string}"
    Sass::Script::Value::String.new("url(#{data_uri})")
  end
  declare(:asset_data, [:url])
end

module MagLove
  module Tilt
    class ScssTemplate < ::Tilt::SassTemplate
      self.default_mime_type = 'text/css'

      def prepare
      end

      def evaluate(scope, locals, &block)
        prepared_data = "@base: \"#{locals[:base_path].sub('src/', '../../')}\";\n#{data}"
        engine = Sass::Engine.new(prepared_data, sass_options.merge({ locals: locals }))
        @output ||= engine.render
      end

      private

      def sass_options
        options.merge(filename: eval_file, line: line, syntax: :scss)
      end
    end
  end
end

Tilt.mappings["scss"] = [MagLove::Tilt::ScssTemplate]
