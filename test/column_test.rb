require 'test_helper'

class ColumnTest < Minitest::Test
  def test_it_assigns_instance_variables
    column = ParseCsv::Column.new(:id, /\A[0-9]+\z/, "ID", ->(a) { a.to_i })

    assert_equal :id, column.name
    assert_equal Regexp.new(/\A[0-9]+\z/), column.format
    assert_equal "ID", column.header
    assert column.transformation.is_a?(Proc)
  end

  def test_it_raises_on_validate_and_transform_value
    assert_raises NotImplementedError do
      column = ParseCsv::Column.new(nil, nil)
      column.validate_and_transform_value(1)
    end
  end

  def test_it_raises_on_default_transformation
    assert_raises NotImplementedError do
      column = ParseCsv::Column.new(nil, nil)
      column.default_transformation(1)
    end
  end

  def test_to_s_returns_header_if_provided
    column = ParseCsv::Column.new(:id, nil, "ID")
    assert_equal "ID", column.to_s
  end

  def test_to_s_returns_name_if_header_is_nil
    column = ParseCsv::Column.new(:id, nil, nil)
    assert_equal "id", column.to_s
  end

  def test_transform_uses_provided_transformation_proc
    column = ParseCsv::Column.new(:id, nil, nil, ->(v) { v.to_i })
    assert_equal 1, column.transform('1')
  end

  def test_transform_uses_default_transformation_proc
    column = ParseCsv::Column.new(:id, nil, nil, nil)
    assert_raises NotImplementedError do
      column.transform('1')
    end
  end
end