# frozen_string_literal: true

require 'logcraft'
require 'sidekiq'

require_relative 'sidekiq/version'

module Logcraft
  module Sidekiq
    autoload :ErrorLogger, 'logcraft/sidekiq/error_logger'
    autoload :DeathLogger, 'logcraft/sidekiq/death_logger'
    autoload :JobContext, 'logcraft/sidekiq/job_context'
    autoload :JobLogger, 'logcraft/sidekiq/job_logger'
  end
end
