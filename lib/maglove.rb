require 'magloft'
require "maglove/workspace"
require "maglove/widgets"
require "maglove/commands/base"
require "maglove/commands/fonts"
require "maglove/commands/theme"
require "maglove/commands/assets"
require "maglove/commands/main"
require "block_resolver"

module Maglove
  def self.theme_config(key = nil, theme)
    @theme_config ||= {}
    unless @theme_config[theme]
      config_file = Workspace::WorkspaceFile.new("src/themes/#{theme}", "theme.yml")
      @theme_config[theme] = config_file.read_yaml
    end
    if key.nil?
      @theme_config[theme]
    else
      @theme_config[theme][key.to_s]
    end
  end

  def self.logger
    if @logger.nil?
      Logging.color_scheme("bright",
                           levels: { debug: :blue, info: :green, warn: :yellow, error: :red, fatal: [:white, :on_red] },
                           date: :blue,
                           mdc: :cyan,
                           logger: :cyan,
                           message: :black)
      Logging.appenders.stdout("stdout", layout: Logging.layouts.pattern(pattern: '[%d] %-5l %-18X{full_command} %x %m\n', color_scheme: 'bright'))
      @logger = Logging::Logger.new(self.class.name)
      @logger.level = :debug
      @logger.add_appenders('stdout')
    end
    @logger
  end
end
