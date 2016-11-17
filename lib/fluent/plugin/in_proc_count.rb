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
    end

    def configure(conf)
      super
      @processes = @processes.map { |process| 
        s = OpenStruct.new
        s.regexp = Regexp.new(process.regexp)
        s.proc_count = process.proc_count
        s.tag = process.tag
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
      begin
        @processes.each do |process_spec|
          records = get_processes(process_spec)
          if process_spec.proc_count != records.size
            router.emit(
              process_spec.tag,
              Fluent::Engine.now,
              {
                regexp: process_spec.regexp.source,
                proc_count: records.size,
                expect_proc_count: process_spec.proc_count,
                hostname: Socket.gethostname
              }
            )
          end
        end
      rescue => e
        log.error e
      end
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
