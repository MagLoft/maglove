require "dialers"
require "magloft/api_caller"
require "magloft/remote_collection"
require "magloft/remote_resource"
require "magloft/transformable"
require "magloft/typeloft_block"
require "magloft/typeloft_image"
require "magloft/typeloft_template"
require "magloft/typeloft_theme"

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
    
    def typeloft_blocks
      TypeloftBlock
    end
  end
end
