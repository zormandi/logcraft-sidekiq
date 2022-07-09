# frozen_string_literal: true

require 'logcraft'
require 'sidekiq'

require_relative 'sidekiq/version'

module Logcraft
  module Sidekiq
    autoload :JobContext, 'logcraft/sidekiq/job_context'
    autoload :JobLogger, 'logcraft/sidekiq/job_logger'
  end
end
