module MagLoft
  class TypeloftImage < RemoteResource
    endpoint "api/maglove/v1/typeloft_images"
    remote_attribute :title, :user_id, :typeloft_folder_id, :typeloft_theme_id, :remote_file, :md5
    attr_accessor :policy, :content_type

    def upload(file_path)
      return false if policy.nil?
      conn = Faraday.new(url: policy["url"]) do |f|
        f.ssl.verify = false
        f.headers = policy["headers"]
        f.adapter :net_http
      end
      response = conn.put(nil, File.read(file_path))
      return (response.status == 200)
    end
    
    def queue_upload(file_path, &block)
      return false if policy.nil?
      request = Typhoeus::Request.new(policy["url"], method: :put, headers: policy["headers"], body: File.read(file_path), timeout: 200000)
      request.on_complete(&block) if block
      request
    end
  end
end
