module MagLoft
  class TypeloftTheme < RemoteResource
    endpoint "api/maglove/v1/typeloft_themes"
    remote_attribute :identifier, :name, :description, :base_version, :widgets, :fonts, :user_id, :screenshots, :active
    attr_accessor :stylesheet_policy, :javascript_policy

    def typeloft_templates
      RemoteCollection.new(TypeloftTemplate, { typeloft_theme_id: self.id })
    end

    def typeloft_images
      RemoteCollection.new(TypeloftImage, { typeloft_theme_id: self.id })
    end

    def typeloft_blocks
      RemoteCollection.new(TypeloftBlock, { typeloft_theme_id: self.id })
    end

    def upload_javascript(file_path)
      return false if javascript_policy.nil?
      conn = Faraday.new(url: javascript_policy["url"]) do |f|
        f.ssl.verify = false
        f.headers = javascript_policy["headers"]
        f.adapter :net_http
      end
      response = conn.put(nil, File.read(file_path))
      return (response.status == 200)
    end

    def upload_stylesheet(file_path)
      return false if stylesheet_policy.nil?
      conn = Faraday.new(url: stylesheet_policy["url"]) do |f|
        f.ssl.verify = false
        f.headers = stylesheet_policy["headers"]
        f.adapter :net_http
      end
      response = conn.put(nil, File.read(file_path))
      return (response.status == 200)
    end
  end
end
