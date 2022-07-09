# frozen_string_literal: true

module Logcraft
  module Sidekiq
    class DeathLogger
      include Logcraft::LogContextHelper

      def call(job, error)
        within_log_context(JobContext.from_job_hash(job)) do
          ::Sidekiq.logger.error error
        end
      end
    end
  end
end
