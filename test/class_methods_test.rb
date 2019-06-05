require 'test_helper'

class ClassMethodsTest < Minitest::Test
  def klass
    @klass ||= Class.new do
      extend ParseCsv::ClassMethods
    end
  end

  def test_it_responds_to_methods
    assert klass.respond_to?(:column)
    assert klass.respond_to?(:columns)
    assert klass.respond_to?(:expected_headers)
  end

  def test_it_pushes_proper_column_class_onto_list_of_columns
    klass.column :id, :integer, //
    assert klass.columns.last.is_a?(ParseCsv::IntegerColumn)

    klass.column :id, :float, //
    assert klass.columns.last.is_a?(ParseCsv::FloatColumn)

    klass.column :id, :date, //
    assert klass.columns.last.is_a?(ParseCsv::DateColumn)

    klass.column :id, :custom, //
    assert klass.columns.last.is_a?(ParseCsv::CustomColumn)

    klass.column :id, :unknown, //
    assert klass.columns.last.is_a?(ParseCsv::CustomColumn)
  end
end