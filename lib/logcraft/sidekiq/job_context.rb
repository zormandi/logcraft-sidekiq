# frozen_string_literal: true

module Logcraft
  module Sidekiq
    class JobContext
      class << self
        def from_job_hash(job_hash)
          return {} if job_hash.nil?
          basic_info_from(job_hash).merge thread_info,
                                          params: named_arguments_from(job_hash)
        end

        private

        def basic_info_from(job)
          info_hash = {jid: job['jid'],
                       queue: job['queue'],
                       worker: job_class(job),
                       created_at: job['created_at'],
                       enqueued_at: job['enqueued_at'],
                       run_count: (job['retry_count'] || -1) + 2}
          info_hash[:bid] = job['bid'] if job['bid']
          info_hash[:tags] = job['tags'] if job['tags']
          info_hash
        end

        def named_arguments_from(job)
          {}.tap do |arguments|
            method_parameters_of(job).each_with_index do |(_, param_name), index|
              arguments[param_name] = job['args'][index]
            end
          end
        end

        def method_parameters_of(job)
          Kernel.const_get(job_class(job)).instance_method(:perform).parameters
        end

        def job_class(job)
          job['wrapped'] || job['class']
        end

        def thread_info
          {tid: Thread.current['sidekiq_tid'] || (Thread.current.object_id ^ ::Process.pid).to_s(36)}
        end
      end
    end
  end
end
