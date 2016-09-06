module MagLoft
  class Transformable < Dialers::Transformable
    def transform_attributes_to_object(entity_class_or_decider, attributes)
      super.clear_changed_data!
    end
    
    def transform_to_existing(entity)
      Dialers::AssignAttributes.call(entity, raw_data)
    end
  end
end
