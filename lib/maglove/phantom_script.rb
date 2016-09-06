require 'tempfile'

module MagLove
  class PhantomScript
    attr_accessor :running, :script, :options, :path, :log_file

    def initialize(script, options = {})
      @running = false
      @script = script
      @options = options.merge({
        script_path: Gem.datadir("maglove")
      })
      @path = File.absolute_path(File.join(@options[:script_path], "#{@script}.js"))
      throw "Script #{script} not found at #{@path}" unless File.exist?(@path)
      @log_file = Tempfile.new('pslog')
    end

    def run(*args)
      start = Time.now
      @running = true
      cmd = "phantomjs #{@path} #{@log_file.path} #{args.join(' ')}"

      # log phantomjs info
      @log_thread = Thread.new do
        f = File.open(@log_file.path, "r")
        f.seek(0, IO::SEEK_END)
        puts "phantom@0ms ▸ (start)"
        while @running
          select([f])
          line = f.gets
          puts "phantom@#{((Time.now - start) * 1000.0).to_i}ms ▸ #{line}" if line
        end
      end

      # run command and return result
      result = `#{cmd}`
      @running = false
      result == "ERROR" ? false : result
    ensure
      @log_file.close
      @log_file.unlink
    end
  end
end
