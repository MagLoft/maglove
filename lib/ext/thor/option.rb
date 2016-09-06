class Thor
  class Option
    attr_reader :validator

    def initialize(name, options = {})
      options[:required] = false unless options.key?(:required)
      super
      @lazy_default = options[:lazy_default]
      @group        = options[:group].to_s.capitalize if options[:group]
      @aliases      = Array(options[:aliases])
      @hide         = options[:hide]
      @validator    = options[:validator]
    end
  end

  class Options
    # Parse the value at the peek analyzing if it requires an input or not.
    #
    def parse_peek(switch, option)
      if parsing_options? && (current_is_switch_formatted? || last?)
        if option.boolean?
          # No problem for boolean types
        elsif no_or_skip?(switch)
          return nil # User set value to nil
        elsif option.string? && !option.required?
          # Return the default if there is one, else the human name
          return option.lazy_default || option.default || option.human_name
        elsif option.lazy_default
          return option.lazy_default
        else
          fail MalformattedArgumentError, "No value provided for option '#{switch}'"
        end
      end

      @non_assigned_required.delete(option)
      if option.validator and !option.validator.validate(switch, peek)
        fail MalformattedArgumentError, option.validator.message(switch, peek)
      end

      send(:"parse_#{option.type}", switch)
    end
  end
end
