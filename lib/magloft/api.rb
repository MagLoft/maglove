require "dialers"
require "magloft/api_caller"
require "magloft/transformable"
require "magloft/remote_resource"
require "magloft/remote_collection"
require "magloft/typeloft_theme"
require "magloft/typeloft_template"
module MagLoft
  class Api < Dialers::Wrapper
    attr_accessor :token

    def self.client(token = nil)
      @client ||= self.new(token)
    end

    def initialize(token)
      @token = token
    end

    def api_caller
      @api_caller ||= ApiCaller.new
    end

    def typeloft_themes
      TypeloftTheme
    end

    def typeloft_templates
      TypeloftTemplate
    end
  end
end
