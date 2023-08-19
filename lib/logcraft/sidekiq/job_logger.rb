# frozen_string_literal: true

module Logcraft
  module Sidekiq
    class JobLogger
      include Logcraft::LogContextHelper

      def initialize(logger = ::Sidekiq.logger)
        @logger = logger
      end

      def call(job_hash, _queue)
        within_log_context(JobContext.from_job_hash(job_hash)) do
          begin
            @logger.info "#{job_hash['class']} started"
            benchmark { yield }
            @logger.info message: "#{job_hash['class']} finished"
          rescue Exception
            @logger.info message: "#{job_hash['class']} failed"
            raise
          end
        end
      end

      def prepare(_job_hash, &_block)
        yield
      end

      private

      def benchmark
        start_time = ::Process.clock_gettime ::Process::CLOCK_MONOTONIC, :millisecond
        yield
      ensure
        end_time = ::Process.clock_gettime ::Process::CLOCK_MONOTONIC, :millisecond
        add_to_log_context duration: end_time - start_time,
                           duration_sec: (end_time - start_time) / 1000.0
      end
    end
  end
end
