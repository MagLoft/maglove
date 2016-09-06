require 'workspace/workspace_dir/archive'
module Workspace
  class WorkspaceDir
    include Workspace::WorkspaceDir::Archive
    
    attr_accessor :workspace, :path
    
    def initialize(workspace, path="")
      @workspace = workspace
      @path = path
    end
    
    def to_s
      File.join(@workspace, @path)
    end
    
    def name
      File.basename(to_s)
    end
    
    def create
      FileUtils.mkdir_p(to_s)
      self
    end
    
    def exists?
      File.directory?(to_s)
    end
    
    def copy(target_dir)
      target_dir.parent_dir.create if !target_dir.parent_dir.exists?
      FileUtils.cp_r(to_s, target_dir.to_s)
    end
    
    def delete!
      FileUtils.rm_rf(to_s)
    end
    
    def reset!
      delete!
      create
    end
    
    def file(file_path)
      WorkspaceFile.new(@workspace, File.join(@path, file_path))
    end
    
    def dir(dir_path)
      self.class.new(@workspace, File.join(@path, dir_path))
    end
    
    def root_dir
      self.class.new(@workspace, "")
    end
    
    def parent_dir
      root_dir.dir(File.expand_path("..", @path))
    end
    
    def children
      entries = []
      Dir.chdir(to_s) do
        Dir["*"].each do |path|
          entries.push(dir(path))
        end
      end
      entries
    end
    
    def files(glob="*")
      entries = []
      Dir.chdir(to_s) do
        Dir[glob].each do |path|
          entries.push(file(path))
        end
      end
      entries
    end
    
    def each_dir(&block)
      children.each do |subdir|
        block.call(subdir)
      end
    end
    
    def absolute_path
      File.absolute_path(to_s)
    end
  end
end
