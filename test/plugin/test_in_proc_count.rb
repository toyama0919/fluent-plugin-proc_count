require 'helper'

class ProcCountInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf)
    Fluent::Test::InputTestDriver.new(Fluent::ProcCountInput).configure(conf)
  end

  def test_configure_full
    d = create_driver %q{
      interval 60s

      <process>
        tag proc_count.fluentd
        regexp bin/fluentd
        proc_count 2
      </process>

      <process>
        tag proc_count.embulk
        regexp embulk
        proc_count 1
      </process>
    }

    assert_equal 'test', d.instance.tag
    assert_equal 10 * 60, d.instance.interval
    assert_equal 'hoge', d.instance.instance_variable_get(:@hoge)
  end

  def test_configure_error_when_config_is_empty
    assert_raise(Fluent::ConfigError) do
      create_driver ''
    end
  end

  def test_emit
    d = create_driver

    d.run do
      sleep 2
    end

    emits = d.emits
    assert_equal true, emits.length > 0
    assert_equal "tag1", emits[0].first
    assert_equal ({"k1"=>"ok"}), emits[0].last
  end
end