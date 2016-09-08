module Maglove
  module Widgets
    class Columns < Base
      attr_reader :columns
      attr_reader :column_count
      attr_reader :total_columns

      def initialize(options)
        super(options)
        @column_count = 0
        column_array = @options[:columns].to_s.split("x")
        if column_array.length == 1
          @total_columns = column_array[0].to_i
          @columns = Array.new(@total_columns) { 12 / @total_columns }
        else
          @total_columns = column_array.length
          @columns = column_array
        end
      end

      def next_span
        value = @columns[@column_count]
        @column_count += 1
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

      module Helpers
        def column(row, &block)
          # get and increase span
          next_span = row.next_span
          if next_span
            phone_cols = row.options[:collapse_options] == "xs" ? next_span : "12"
            haml_tag :div, class: "column col-#{phone_cols} col-tablet-#{next_span} col-#{row.options[:collapse_options]}-#{next_span}" do
              yield if block
              drop_container
            end
          else
            haml_tag :pre do
              haml_concat "ERROR: Row does not allow column at position #{row.column_count}"
            end
          end
        end

        def columns_widget(options = {}, &block)
          widget_block(Widgets::Columns.new(options)) do |widget|
            haml_tag :div, widget.row_options do
              yield(widget) if block
            end
          end
        end

        def columns_widget_compose(key, options = {}, &block)
          columns_widget = Widgets::Columns.new(options)
          items = variable(key, [])
          # calculate row and column count
          row_count = (items.length.to_f / columns_widget.total_columns).ceil
          col_count = columns_widget.total_columns
          (0...row_count).each do |row_index|
            columns_widget(options) do |row|
              (0...col_count).each do |col_index|
                index = (row_index * col_count) + col_index
                yield(row, items[index]) unless items[index].nil?
              end
            end
          end
        end
      end
    end
  end
end
