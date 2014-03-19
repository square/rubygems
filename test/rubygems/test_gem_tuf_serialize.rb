require 'rubygems/test_case'
require 'rubygems/command'
require 'rubygems/tuf'

class TestGemTUFSerialize < Gem::TestCase
  def setup
    super
  end

  def test_sorted_json
    expected = %q[{"a":"b","c":"d","w":{"a":"a","x":"n"}}]
    actual = Gem::TUF::Serialize.dump({ "c" => "d", "a" => "b", "w" => { "x" => "n", "a" => "a" } })
    assert_equal expected, actual
  end

  def test_simple_case
    expected = %q[{"a":"b"}]
    actual = Gem::TUF::Serialize.dump({ :a => "b" })
    assert_equal expected, actual
  end

  def test_fixnums
    expected = %q[{"a":42}]
    actual = Gem::TUF::Serialize.dump({ "a" => 42 })
    assert_equal expected, actual
  end

  def test_newlines_in_string_value
    expected = %q[{"a":"I\nlike\rturtles!"}]
    actual = Gem::TUF::Serialize.dump({ "a" => "I\nlike\rturtles!" })
    assert_equal expected, actual
  end

  def test_array_values
    expected = %q[{"a":[1,2,3,5]}]
    actual = Gem::TUF::Serialize.dump({ "a" => [1,2,3,5] })
    assert_equal expected, actual
  end

  def test_raise_for_float
    assert_raises TypeError do
      Gem::TUF::Serialize.dump({ :a => 1.5 })
    end
  end

  def test_booleans
    expected = %q[{"a":"true"}]
    actual = Gem::TUF::Serialize.dump({ "a" => true })
    assert_equal expected, actual
  end

  def test_nil
    expected = %q[{"a":null}]
    actual = Gem::TUF::Serialize.dump({ "a" => nil })
    assert_equal expected, actual
  end
end
