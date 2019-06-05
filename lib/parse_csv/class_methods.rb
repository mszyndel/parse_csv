module ParseCsv
  module ClassMethods
    def column(name, type, format, header = nil, transformation = nil)
      case type
      when :integer
        klass = IntegerColumn
      when :float
        klass = FloatColumn
      when :date
        klass = DateColumn
      else
        klass = CustomColumn
      end

      @columns ||= []
      @columns << klass.new(name, format, header, transformation)
    end

    def expected_headers
      columns.map {|column| column.header }
    end

    def columns
      @columns || []
    end
  end
end
