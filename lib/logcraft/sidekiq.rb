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

    def self.initialize
      ::Sidekiq.logger = Logcraft.logger 'Sidekiq'
      ::Sidekiq.configure_server do |config|
        config[:job_logger] = JobLogger
        config.error_handlers.delete_if do |handler|
          (defined?(::Sidekiq::ExceptionHandler) && defined?(::Sidekiq::ExceptionHandler::Logger) && handler.is_a?(::Sidekiq::ExceptionHandler::Logger)) ||
            (handler.is_a?(Method) && handler.receiver.name == 'Sidekiq' && handler.name == :default_error_handler)
        end
        config.error_handlers << ErrorLogger.new
        config.death_handlers << DeathLogger.new
      end
    end
  end
end
