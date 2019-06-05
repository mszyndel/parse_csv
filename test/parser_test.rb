require 'test_helper'

class ParserTest < Minitest::Test
  def klass
    Class.new(ParseCsv::Parser) do
      column :id, :integer, /[0-9]+/, 'ID'
      column :balance, :float, /[0-9]+\.[0-9]{2}/, 'Balance'
    end
  end

  def valid_data
    <<CSV
ID,Balance
1,1234.45
2,49284.84
3,1334.02
CSV
  end

  def invalid_headers
    <<CSV
op_id,final_balance
1,1234.45
2,49284.84
3,1334.02
CSV
  end

  def invalid_data
    <<CSV
ID,Balance
1,1234.45
2,asdf
HA,1334.02
CSV
  end

  def test_getters
    parser = klass.new('')
    assert parser.respond_to?(:errors)
    assert parser.respond_to?(:raw_data)
    assert parser.respond_to?(:parsed_data)
  end

  def test_it_validates_and_transforms_the_data
    parser = klass.new(valid_data)
    parser.validate_and_transform
    assert_equal [[1, 1234.45], [2, 49284.84], [3, 1334.02]], parser.parsed_data
  end

  def test_it_adds_error_for_each_invalid_value
    parser = klass.new(invalid_data)
    parser.validate_and_transform
    assert_equal [[1, 1234.45]], parser.parsed_data
    assert_includes parser.errors, "Invalid value asdf for column Balance in line 2"
    assert_includes parser.errors, "Invalid value HA for column ID in line 3"
  end

  def test_it_separates_headers_from_data_if_provided
    parser = klass.new(valid_data)
    assert parser.raw_data.is_a?(Array)
    assert_equal 3, parser.raw_data.length
    assert_equal ['ID', 'Balance'], parser.instance_variable_get(:@headers)
  end

  def test_it_validates_headers_if_provided
    parser = klass.new(invalid_headers)
    parser.validate_and_transform
    assert_includes parser.errors, 'Invalid headers'
  end

  def test_it_passes_each_row_to_validate_and_transform_row
    mocked_validate_and_transform_row = MiniTest::Mock.new
    mocked_validate_and_transform_row.expect :call, [true, [1]], [0]
    mocked_validate_and_transform_row.expect :call, [true, [2]], [1]
    mocked_validate_and_transform_row.expect :call, [true, [3]], [2]
    parser = klass.new(valid_data)
    parser.stub :validate_and_transform_row, mocked_validate_and_transform_row do
      parser.validate_and_transform
    end
    mocked_validate_and_transform_row.verify

    assert_equal [[1], [2], [3]], parser.parsed_data
  end

  def test_it_excludes_invalid_rows_from_parsed_data
    mocked_validate_and_transform_row = MiniTest::Mock.new
    mocked_validate_and_transform_row.expect :call, [true, [1, 1234.45]], [0]
    mocked_validate_and_transform_row.expect :call, [false, [2, 49284.84]], [1]
    mocked_validate_and_transform_row.expect :call, [true, [3, 1334.02]], [2]

    parser = klass.new(valid_data)
    parser.stub :validate_and_transform_row, mocked_validate_and_transform_row do
      parser.validate_and_transform
    end
    mocked_validate_and_transform_row.verify

    assert_equal [[1, 1234.45], [3, 1334.02]], parser.parsed_data
  end

  def test_validates_and_transforms_each_column_in_a_row
    column_id = MiniTest::Mock.new
    column_id.expect :validate_and_transform_value, [true, 1], ['1']
    column_balance = MiniTest::Mock.new
    column_balance.expect :validate_and_transform_value, [true, 1234.45], ['1234.45']

    parser = klass.new(valid_data)
    parser.class.instance_variable_set(:@columns, [column_id, column_balance])
    parser.validate_and_transform_row(0)

    column_id.verify
    column_balance.verify
  end
end
