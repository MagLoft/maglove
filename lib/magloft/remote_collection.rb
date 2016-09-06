module MagLoft
  class RemoteCollection
    def initialize(resource_class, filter={})
      @resource_class = resource_class
      @filter = filter
    end
    
    def new(attributes)
      entity = @resource_class.new(attributes.merge(@filter))
    end
    
    def find(id)
      @resource_class.where(@filter.merge(id: id)).first
    end
    
    def where(params)
      @resource_class.where(params.merge(@filter))
    end
    
    def find_one(params)
      @resource_class.find_one(params.merge(@filter))
    end
    
    def all
      @resource_class.where(@filter)
    end
    
    def method_missing(name, *args, &block)
      if name[0..7] == "find_by_" and args.length == 1
        attribute = name[8..-1].to_sym
        if @resource_class.remote_attributes.include?(attribute)
          params = {}
          params[attribute] = args.first
          return self.find_one(params.merge(@filter))
        end
      end
      super
    end
    
    def create(attributes={})
      entity = @resource_class.new(attributes.merge(@filter))
      entity.save
      entity
    end
  end
end
