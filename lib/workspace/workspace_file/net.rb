require "open-uri"
require "open_uri_redirections"

module Workspace
  class WorkspaceFile
    module Net
      extend ActiveSupport::Concern

      def download(url)
        url = "http:#{url}" if url[0..1] == "//"
        contents = open(url, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, allow_redirections: :safe }).read
        dir.create if !dir.exists?
        write(contents)
        self
      end
    end
  end
end
