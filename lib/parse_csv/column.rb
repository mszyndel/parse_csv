module ParseCsv
  class Column
    attr_reader :name, :format, :header, :transformation

    def initialize(name, format, header = nil, transformation = nil)
      @name = name
      @format = format
      @header = header
      @transformation = transformation
    end

    def validate_and_transform_value(value)
      raise NotImplementedError
    end

    def transform(value)
      if @transformation.is_a?(Proc)
        @transformation.call(value)
      else
        default_transformation(value)
      end
    end

    def default_transformation(value)
      raise NotImplementedError
    end

    def to_s
      (@header || @name).to_s
    end
  end

  class IntegerColumn < Column
    FORMATS = {
      signed: /\A\-?\+?[0-9]+\z/,
      unsigned: /\A[0-9]+\z/
    }

    def validate_and_transform_value(value)
      match = value.match(@format)
      return [false, nil] unless !!match

      [true, transform(match[0])]
    end

    def default_transformation(value)
      value.to_i
    end
  end

  class FloatColumn < Column
    FORMATS = {
      signed: /\A(\-|\+)?[0-9]+\.[0-9]+\z/
    }

    def validate_and_transform_value(value)
      match = value.match(@format)
      return [false, nil] unless !!match

      [true, transform(match[0])]
    end

    def default_transformation(value)
      value.to_f
    end
  end

  class DateColumn < Column
    def validate_and_transform_value(value)
      parsed_value = Date.strptime(value, @format)

      [true, transform(parsed_value)]
    rescue => e
      puts e.inspect
      [false, nil]
    end

    def default_transformation(value)
      value
    end
  end

  class CustomColumn < Column
    def validate_and_transform_value(value)
      match = value.match(@format)
      return [false, nil] unless !!match

      [true, transform(match[0])]
    end

    def default_transformation(value)
      value
    end
  end
end
