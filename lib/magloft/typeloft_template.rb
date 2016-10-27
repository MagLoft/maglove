module MagLoft
  class TypeloftTemplate < RemoteResource
    endpoint "api/maglove/v1/typeloft_templates"
    remote_attribute :identifier, :title, :contents, :public, :position, :typeloft_theme_id, :user_id, :created_at, :updated_at
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
    
    def queue_upload_thumbnail(file_path, &block)
      return false if thumbnail_policy.nil?
      request = Typhoeus::Request.new(thumbnail_policy["url"], method: :put, headers: thumbnail_policy["headers"], body: File.read(file_path), timeout: 200000)
      request.on_complete(&block) if block
      request
    end
  end
end
