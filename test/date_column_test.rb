require 'test_helper'

class DateColumnTest < Minitest::Test
  def test_it_uses_provided_format
    column = ParseCsv::DateColumn.new(:created_at, '%Y-%m-%d')
    assert_equal [true, Date.new(2019, 6, 3)], column.validate_and_transform_value('2019-06-03T23:58:14+00:00')

    column = ParseCsv::DateColumn.new(:created_at, '%d-%b-%y')
    assert_equal [true, Date.new(2019, 6, 3)], column.validate_and_transform_value('3-Jun-19')

    column = ParseCsv::DateColumn.new(:created_at, '%Y-%m-%d')
    assert_equal [false, nil], column.validate_and_transform_value('2019-06')
  end

  def test_it_uses_default_transformation
    column = ParseCsv::DateColumn.new(:created_at, nil)
    assert_equal Date.new(2019, 6, 3), column.transform(Date.new(2019, 6, 3))
  end

  def test_it_uses_provided_transformation
    column = ParseCsv::DateColumn.new(:created_at, '%Y-%m-%d', nil, ->(v) { v.strftime('%s') })
    assert_equal [true, '1559520000'], column.validate_and_transform_value('2019-06-03')
  end
end
