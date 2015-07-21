module Commander
  class Command
    attr_accessor :block

    class Options
      
      def __merge(params)
        options = Options.new
        options.__hash__.merge!(__hash__)
        options.__hash__.merge!(params)
        options
      end
      
    end

    def invoke(args=[], options=nil)
      options ||= Options.new
      self.block.call(args, options)
    end
    
    def task_action(*args, &block)
      when_called(*args, &block)
      self.block = block
    end

  end
end
