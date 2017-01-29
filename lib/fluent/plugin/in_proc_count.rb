require 'fluent/input'
require 'sys/proctable'
require 'ostruct'

module Fluent
  class ProcCountInput < Fluent::Input
    Plugin.register_input 'proc_count', self
    include Sys

    def initialize
      super
    end

    config_param :interval, :time, default: '5m'

    config_section :process, required: true, param_name: :processes do
      config_param :tag, :string
      config_param :regexp, :string
      config_param :proc_count, :integer, default: 1
      config_param :operator_name, :string, default: "equal"
    end

    def configure(conf)
      super
      @processes = @processes.map { |process|
        s = OpenStruct.new
        s.regexp = Regexp.new(process.regexp)
        s.proc_count = process.proc_count
        s.tag = process.tag
        s.operator_name = process.operator_name
        s.operator = select_operator(process.operator_name)
        s
      }
    end

    def start
      super
      @thread = Thread.new(&method(:run))
    end

    def shutdown
      super
      Thread.kill(@thread)
    end

    def run
      loop do
        Thread.new(&method(:emit_proc_count))
        sleep @interval
      end
    end

    def emit_proc_count
      @processes.each do |process_spec|
        begin
          record_size = get_processes(process_spec).size
          if !correct_process?(process_spec, record_size)
            router.emit(
              process_spec.tag,
              Fluent::Engine.now,
              {
                regexp: process_spec.regexp.source,
                proc_count: record_size,
                expect_proc_count: process_spec.proc_count,
                operator_name: process_spec.operator_name,
                hostname: Socket.gethostname
              }
            )
          end
        rescue => e
          log.error e
        end
      end
    end

    def select_operator(operator_name)
      case operator_name.to_sym
      when :equal
        "=="
      when :gather_than
        ">"
      when :gather_equal
        ">="
      when :less_than
        "<"
      when :less_equal
        "<="
      else
        raise Fluent::ConfigError, "proc_count operator allows equal/gather_than/gather_equal/less_than/less_equal"
      end
    end

    def correct_process?(process_spec, expect_proc_count)
      expect_proc_count.public_send(process_spec.operator, process_spec.proc_count.to_i)
    end

    def get_processes(process_spec)
      processes = []
      ProcTable.ps do |process|
        if process_spec.regexp.match(process.cmdline)
          processes << process
        end
      end
      processes
    end
  end
end
