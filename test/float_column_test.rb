require 'test_helper'

class FloatColumnTest < Minitest::Test
  def test_it_uses_provided_format
    column = ParseCsv::FloatColumn.new(:price, /\A[0-9]+(\.[0-9]*)?\z/)
    assert_equal [true, 1234.567], column.validate_and_transform_value('1234.567')

    column = ParseCsv::FloatColumn.new(:price, /[0-9]+(\.[0-9]{2})?/)
    assert_equal [true, 1234.56], column.validate_and_transform_value('1234.567')
  end

  def test_it_uses_default_transformation
    column = ParseCsv::FloatColumn.new(:price, nil)
    assert_equal 1.23, column.transform('1.23')
  end

  def test_it_uses_provided_transformation
    column = ParseCsv::FloatColumn.new(:price, /\A[0-9]+(\.[0-9]*)?\z/, nil, ->(v) { v.to_f.round(2) })
    assert_equal [true, 1234.57], column.validate_and_transform_value('1234.5678')

    column = ParseCsv::FloatColumn.new(:price, /\A[0-9]{1,3}(\ [0-9]{3})(\.[0-9]*)?\z/, nil, ->(value) { value.gsub(/\s/, '').to_f })
    assert_equal [true, 12345.678], column.validate_and_transform_value('12 345.678')
  end
end
