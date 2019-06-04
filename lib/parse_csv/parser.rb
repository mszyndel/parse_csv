require 'csv'

module ParseCsv
  class Parser
    extend ParseCsv::ClassMethods

    attr_reader :errors, :parsed_data

    def initialize(data)
      @errors      = []
      @raw_data    = CSV.new(data, headers: false, liberal_parsing: true).read
      @headers     = []
      if expect_headers?
        @headers = @raw_data.shift
      end
      @parsed_data = []
    end

    def validate_and_transform
      validate_headers

      @raw_data.each_with_index do |_, i|
        valid, transformed_row = *validate_and_transform_row(i)
        if valid
          @parsed_data << transformed_row
        end
      end

      @parsed_data
    end

    def validate_headers
      unless @headers == self.class.expected_headers
        @errors << "Invalid headers"
      end
    end

    def validate_and_transform_row(row_index)
      row_valid = true

      transformed_row = self.class.columns.map.with_index do |column, column_index|
        value = @raw_data[row_index][column_index].strip
        column_valid, transformed_value = column.validate_and_transform_value(value)

        unless column_valid
          @errors << "Invalid value #{value} for column #{column.to_s} in line #{row_index + 1}"
        end

        row_valid = row_valid && column_valid

        transformed_value
      end

      [row_valid, transformed_row]
    end

    def expect_headers?
      self.class.expected_headers.any?
    end

    def to_h
      column_names = self.class.columns.map(&:name)
      @parsed_data.map do |row|
        Hash[column_names.zip(row)]
      end
    end
  end
end
