# frozen_string_literal: true

module Logcraft
  module Sidekiq
    class ErrorLogger
      include Logcraft::LogContextHelper

      def call(error, context, _config = nil)
        within_log_context(JobContext.from_job_hash(context[:job])) do
          ::Sidekiq.logger.warn error
        end
      end
    end
  end
end
