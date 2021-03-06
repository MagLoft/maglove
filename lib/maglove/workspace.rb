module Workspace
  def theme_dir(root: "src", theme: options[:theme])
    workspace_dir("#{root}/themes/#{theme}")
  end

  def theme_file(path, root: "src", theme: options[:theme])
    workspace_file("#{root}/themes/#{theme}", path)
  end

  def theme_base_file(path, theme: options[:theme])
    theme_base_dir(theme: theme).file(path)
  end

  def theme_base_dir(theme: options[:theme])
    base_version = theme_config(:base_version, theme: theme)
    workspace_dir("src/base/#{base_version}")
  end

  def gem_dir
    workspace_dir(Gem.datadir("maglove"))
  end

  def theme_config(key = nil, theme: options[:theme])
    Maglove.theme_config(key, theme)
  end

  class WorkspaceFile
    def asset(theme: workspace_theme, base: false, asset_uri: ".")
      MagLove::Asset::Theme.new(path, { theme: theme, base: base, asset_uri: asset_uri })
    end

    def workspace_theme
      match = self.workspace.match(%r{/themes/([^/]+)})
      match ? match[1] : nil
    end

    def read_hamloft(options = {})
      Hamloft.render(read, options)
    end
  end
end
