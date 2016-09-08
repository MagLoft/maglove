module MagLoft
  class TypeloftBlock < RemoteResource
    endpoint "api/maglove/v1/typeloft_blocks"
    remote_attribute :identifier, :name, :contents, :typeloft_theme_id, :user_id, :created_at, :updated_at
    attr_accessor :thumbnail_policy
    
    def upload_thumbnail(file_path)
      return false if thumbnail_policy.nil?
      conn = Faraday.new(url: thumbnail_policy["url"]) do |f|
        f.ssl.verify = false
        f.headers = thumbnail_policy["headers"]
        f.adapter :net_http
      end
      response = conn.put(nil, File.read(file_path))
      return (response.status == 200)
    end
  end
end
