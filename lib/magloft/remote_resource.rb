module MagLoft
  class RemoteResource
    attr_accessor :changed_data
    attr_reader :destroyed

    def initialize(attributes = {})
      allowed_attributes = attributes.slice(*self.class.remote_attributes)
      Dialers::AssignAttributes.call(self, allowed_attributes.without(:id))
    end

    def destroyed?
      self.destroyed == true
    end

    def save
      return false if destroyed? or self.changed_data.keys.count <= 0
      if self.changed_data.keys.count > 0
        if self.id.nil?
          transformable = Api.client.api_caller.post(self.class.endpoint, self.changed_data)
        else
          transformable = Api.client.api_caller.put("#{self.class.endpoint}/#{self.id}", self.changed_data.without(:id))
        end
        transformable.transform_to_existing(self)
        self.clear_changed_data!
      end
      self
    end

    def destroy
      return false if self.id.nil? or self.destroyed?
      transformable = Api.client.api_caller.delete("#{self.class.endpoint}/#{self.id}")
      transformable.transform_to_existing(self)
      @destroyed = true
      self.clear_changed_data!
      self
    end

    def changed_data
      @changed_data ||= {}
    end

    def clear_changed_data!
      self.changed_data = {}
      self
    end

    class << self
      def remote_attributes
        @remote_attributes ||= []
      end

      def remote_attribute(*args)
        args.each do |arg|
          remote_attributes.push(arg)
          self.class_eval("attr_accessor :#{arg}")
          self.class_eval("def #{arg}=(val);@#{arg}=val;changed_data[:#{arg}]=val;end")
        end
      end

      def endpoint(path = nil)
        if path.nil?
          @endpoint
        else
          @endpoint = path
        end
      end

      def find(id)
        api.get("#{endpoint}/#{id}").transform_to_one(self)
      end

      def find_one(params)
        where(params).first
      end

      def where(params)
        api.get(endpoint, params).transform_to_many(self)
      end

      def all
        api.get(endpoint).transform_to_many(self)
      end

      def create(attributes = {})
        entity = self.new(attributes)
        entity.save
        entity
      end

      def method_missing(name, *args, &block)
        if name[0..7] == "find_by_" and args.length == 1
          attribute = name[8..-1].to_sym
          if remote_attributes.include?(attribute)
            params = {}
            params[attribute] = args.first
            return self.find_one(params)
          end
        end
        super
      end

      private

      def api
        Api.client.api_caller
      end
    end
  end
end
