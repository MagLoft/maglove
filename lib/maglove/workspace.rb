module Workspace
  @@config = {}

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
    base_version = theme_config(:base_version, theme)
    workspace_dir("src/base/#{base_version}")
  end

  def gem_dir
    workspace_dir(Gem.datadir("maglove"))
  end

  def theme_config(key = nil, theme = options[:theme])
    unless @@config[theme]
      @@config[theme] = theme_dir.file("theme.yml").read_yaml
    end
    if key.nil?
      @@config[theme]
    else
      @@config[theme][key.to_s]
    end
  end

  class WorkspaceFile
    def asset(theme: workspace_theme, base: false)
      MagLove::Asset::Theme.new(path, { theme: theme, base: base })
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
