require 'erb'
module Haml
  class StyleBuilder
    attr_accessor :options
    attr_accessor :styles

    def initialize(options, styles=[])
      @options = {}
      @styles = {}
      
      # build sanitized options
      options.each do |k, v|
        @options[sanitize_style(k)] = v
      end
      
      # add initial styles
      add_multi(styles)
    end
    
    def process(block=nil)
      block.call(self) if block
      result = @styles.map{|k, v|"#{k}: #{v};"}.join(" ")
      result.empty? ? nil : result
    end
  
    def add_multi(styles)
      styles.each do |style|
        add(style)
      end
    end
    
    def add(style, value=nil, template=nil)
      style = sanitize_style(style)
      
      # handle empty value field
      if (not value or value.empty?) and not (not @options[style] or @options[style].empty?)
        value = @options[style]
      end
      
      # apply template
      if value and not value.empty? and template and not template.empty?
        value = ERB.new(template).result(binding)
      end
      
      @styles[style] = value if value and not value.empty?
    end
    
    def sanitize_style(value)
      value.to_s.gsub(/([A-Z]+)([A-Z][a-z])/,'\1-\2').
      gsub(/([a-z\d])([A-Z])/,'\1-\2').
      tr("_", "-").downcase
    end
  
  end
end