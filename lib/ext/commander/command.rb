module Commander
  class Command
    attr_accessor :block

    class Options
      
      def __merge(params)
        new_options = self.__clone
        new_options.__hash__.merge!(params)
        new_options
      end
      
      def __clone
        new_options = Options.new
        new_options.__hash__.merge!(__hash__)
        new_options
      end
      
    end

    def invoke(args=[], options=nil)
      options = options ? options.__clone : Options.new
      self.block.call(args, options)
    end
    
    def task_action(*args, &block)
      when_called(*args, &block)
      self.block = block
    end

  end
end
