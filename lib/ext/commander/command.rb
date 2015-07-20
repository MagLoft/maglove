module Commander
  class Command
    attr_accessor :block

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
