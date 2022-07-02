# frozen_string_literal: true

require_relative "sidekiq/version"

module Logcraft
  module Sidekiq
    autoload :JobContext, 'logcraft/sidekiq/job_context'
  end
end
