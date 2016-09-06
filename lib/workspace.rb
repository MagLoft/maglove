require "workspace/workspace_dir"
require "workspace/workspace_file"
module Workspace
  def workspace_dir(workspace, path="")
    Workspace::WorkspaceDir.new(workspace, path)
  end
  
  def workspace_file(workspace, path="")
    Workspace::WorkspaceFile.new(workspace, path)
  end
end
