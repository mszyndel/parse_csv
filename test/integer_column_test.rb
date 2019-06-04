require 'test_helper'

class IntegerColumnTest < Minitest::Test
  def test_it_uses_provided_format
    column = ParseCsv::IntegerColumn.new(:id, /\A[0-9]*\z/)
    assert_equal [true, 1234], column.validate_and_transform_value('1234')

    column = ParseCsv::IntegerColumn.new(:id, /\A[0-9]+(\.[0-9]{2})?\z/)
    assert_equal [true, 1234], column.validate_and_transform_value('1234.56')
  end

  def test_it_uses_default_transformation
    column = ParseCsv::IntegerColumn.new(:id, nil)
    assert_equal 1, column.transform('1')
  end

  def test_it_uses_provided_transformation
    column = ParseCsv::IntegerColumn.new(:id, /\A[0-9]*\z/, nil, ->(v) { v.to_i.to_s(16) })
    assert_equal [true, '1337'], column.validate_and_transform_value('4919')

    column = ParseCsv::IntegerColumn.new(:id, /\A[0-9]{1,3}(\ [0-9]{3})*\z/, nil, ->(value) { value.gsub(/\s/, '').to_i })
    assert_equal [true, 12345678], column.validate_and_transform_value('12 345 678')
  end
end
