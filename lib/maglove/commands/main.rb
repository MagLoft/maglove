module MagLove
  module Commands
    class Main < Base
      class_option :asset_uri, type: :string, default: ""

      desc "fonts SUBCOMMAND ...ARGS", "manage fonts"
      subcommand "fonts", Commands::Fonts
    
      desc "theme SUBCOMMAND ...ARGS", "manage theme"
      subcommand "theme", Commands::Theme
      
      desc "assets SUBCOMMAND ...ARGS", "compile theme"
      subcommand "assets", Commands::Assets
            
      desc "compile", "Compile all themes"
      def compile
        workspace_dir("src/themes").each_dir do |dir|
          theme = dir.name
          info("COMPILING THEME #{theme}")
          invoke(Assets, :compile, [], theme: theme)
          reset_command_invocations(Assets)
        end
      end
    end
  end
end
