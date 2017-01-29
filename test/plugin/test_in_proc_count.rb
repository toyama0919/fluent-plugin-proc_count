require 'helper'

class ProcCountInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %q{
    interval 60s

    <process>
      tag proc_count.test
      regexp foobarbuzz
      proc_count 0
    </process>
    }

  def create_driver(conf = CONFIG)
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
        operator_name less_than
      </process>
    }

    assert_equal 60, d.instance.interval

    process_conf1 =  d.instance.processes.first
    assert_equal 'proc_count.fluentd', process_conf1.tag
    assert_equal 'bin/fluentd', process_conf1.regexp.match('bin/fluentd -c')[0]
    assert_equal 'equal', process_conf1.operator_name
    assert_equal '==', process_conf1.operator

    process_conf2 =  d.instance.processes.last
    assert_equal 'proc_count.embulk', process_conf2.tag
    assert_equal 'less_than', process_conf2.operator_name
    assert_equal '<', process_conf2.operator
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
    assert_equal true, emits.length.zero?
    assert_equal true, emits[0].nil?
  end
end
