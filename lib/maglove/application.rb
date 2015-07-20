module MagLove
  class Application
    include Commander::Methods
    
    def run
      program :version, MagLove::VERSION
      program :description, 'MagLoft Themes Toolkit'
      program :help, 'Author', 'Tobias Strebitzer <tobias.strebitzer@magloft.com>'
      program :help, 'Website', 'http://www.magloft.com'
      program :help_formatter, Commander::HelpFormatter::TerminalCompact
      global_option '-x', '--verbose' do
        logger.level = :debug
      end
      global_option '--verbosity LEVEL', 'Specify verbosity level (*info*, debug, warn, error)' do |verbosity|
        verbosity = "info" if !["info", "debug", "warn", "error"].include?(verbosity.to_s)
        logger.level = verbosity.to_sym
      end
      global_option '--production'
      default_command :help
      
      logger.level = ENV["LOG_LEVEL"].to_sym if ENV["LOG_LEVEL"]
      
      MagLove::Command::Theme.new.run
      MagLove::Command::Core.new.run
      MagLove::Command::Compile.new.run
      MagLove::Command::Compress.new.run
      MagLove::Command::Copy.new.run
      MagLove::Command::Util.new.run
      MagLove::Command::Font.new.run
      MagLove::Command::Sync.new.run
      MagLove::Command::Server.new.run
      
      # allow colons
      ARGV[0] = ARGV[0].gsub(":", "-") if ARGV[0]
      
      # merge first two commands
      if ARGV.length > 1 and defined_commands.keys.include?("#{ARGV[0]}-#{ARGV[1]}")
        ARGV[0] = "#{ARGV[0]}-#{ARGV[1]}"
        ARGV.slice!(1)
      end
      
      run!
    end
    
  end
end
