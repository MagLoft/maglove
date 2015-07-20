module Haml
  module Helpers
    class Columns < Base
      attr_reader :columns
      attr_reader :column_count

      def initialize(options)
        super(options)
        @column_count = 0
        column_array = @options[:columns].to_s.split("x")
        if column_array.length == 1
          col_count = column_array[0].to_i
          @columns = Array.new(col_count) { 12 / col_count }
        else
          @columns = column_array
        end
      end
      
      def next_span
        value = @columns[@column_count]
        @column_count = @column_count + 1
        value
      end
      
      def row_options
        {
          class: "row row-#{@options[:style]}",
          style: style_string(@options, :margin_bottom)
        }
      end
      
      def identifier
        "columns"
      end

      def defaults
        {
          columns: "2",
          style: "default",
          margin_bottom: "",
          collapse_options: "sm"
        }
      end
      
    end
  end
end