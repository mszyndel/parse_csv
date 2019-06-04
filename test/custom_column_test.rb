require 'test_helper'

class CustomColumnTest < Minitest::Test
  def test_it_uses_provided_format
    column = ParseCsv::CustomColumn.new(:name, /^(\S+ )+(\S+)$/, nil, ->(v) { v.to_s })
    assert_equal [true, 'John Wick'], column.validate_and_transform_value('John Wick')
  end

  def test_it_uses_default_transformation
    column = ParseCsv::CustomColumn.new(:created_at, /\w+/)
    assert_equal 'John Wick', column.transform('John Wick')
  end

  def test_it_uses_provided_transformation
    regexp = /^(\S+ )+(\S+)$/
    transformation = Proc.new do |value|
      matches     = value.match(regexp).to_a
      last_name   = matches.pop
      first_names = matches[1..-1].join(' ')
      "#{last_name}, #{first_names}".strip
    end

    column = ParseCsv::CustomColumn.new(:name, regexp, nil, transformation)
    assert_equal [true, 'Wick, John'], column.validate_and_transform_value('John Wick')
  end
end
