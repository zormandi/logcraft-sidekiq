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
          info_hash = {
            jid: job['jid'],
            queue: job['queue'],
            worker: job_class(job),
            created_at: time_from(job['created_at']).iso8601(3),
            enqueued_at: time_from(job['enqueued_at']).iso8601(3),
            run_count: (job['retry_count'] || -1) + 2
          }
          info_hash[:bid] = job['bid'] if job['bid']
          info_hash[:tags] = job['tags'] if job['tags']
          info_hash[:cattr] = job['cattr'] if job['cattr']
          info_hash
        end

        # Sidekiq 8 stores the timestamps as integer epoch milliseconds, earlier versions as float
        # epoch seconds. Decided by type, as Sidekiq::JobRecord#time_from_timestamp does: a Sidekiq 8
        # process still runs retries and scheduled jobs enqueued by an older one.
        def time_from(timestamp)
          return Time.at(timestamp) if timestamp.is_a?(Float)

          Time.at(timestamp / 1000, timestamp % 1000, :millisecond)
        end

        def named_arguments_from(job)
          {}.tap do |arguments|
            params, arg_index = method_parameters_of(job), 0
            params.each do |param_type, param_name|
              if param_type == :rest
                rest_arg_count = job['args'].count - params.count + 1
                arguments[param_name] = job['args'].slice arg_index, rest_arg_count
                arg_index += rest_arg_count
              else
                arguments[param_name] = job['args'][arg_index]
                arg_index += 1
              end
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
