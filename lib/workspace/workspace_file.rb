require 'workspace/workspace_file/archive'
require 'workspace/workspace_file/media'
require 'workspace/workspace_file/net'
require 'workspace/workspace_file/parse'

module Workspace
  class WorkspaceFile
    include Workspace::WorkspaceFile::Archive
    include Workspace::WorkspaceFile::Media
    include Workspace::WorkspaceFile::Net
    include Workspace::WorkspaceFile::Parse

    attr_accessor :workspace, :path

    def initialize(workspace, path)
      @workspace = workspace
      @path = path
    end

    def set(data)
      @contents = data
      self
    end

    def contents
      @contents ||= read
    end

    def replace(key, value)
      contents.gsub!(key, value)
      self
    end

    def write(data = nil)
      data ||= @contents
      dir.create unless dir.exists?
      File.open(to_s, "wb") { |file| file << data }
      self
    end

    def copy(target_file)
      target_file.dir.create unless target_file.dir.exists?
      FileUtils.cp(to_s, target_file.to_s)
    end
    
    def move(target_file)
      target_file.dir.create unless target_file.dir.exists?
      FileUtils.mv(to_s, target_file.to_s)
    end

    def to_s
      File.join(@workspace, @path)
    end

    def relative_path
      @path.sub(%r{^/}, "")
    end

    def exists?
      File.exist?(to_s) and !File.directory?(to_s)
    end

    def read
      File.open(to_s).read
    end

    def dir
      Workspace::WorkspaceDir.new(@workspace, File.dirname(@path))
    end

    def md5
      Digest::MD5.hexdigest(read)
    end

    def url
      "file://#{absolute_path}"
    end

    def delete!
      FileUtils.rm_f(to_s)
    end

    def basename
      File.basename(path, ".*")
    end

    def slug
      relative_path.chomp(File.extname(self.relative_path))
    end

    def extension
      File.extname(to_s).gsub(/^\./, "")
    end

    def rename!(filename)
      FileUtils.mv(to_s, dir.file(filename).to_s) if exists?
      @path = dir.file(filename).path
    end

    def absolute_path
      File.absolute_path(to_s)
    end
    
    def size
      File.size(to_s)
    end
  end
end
