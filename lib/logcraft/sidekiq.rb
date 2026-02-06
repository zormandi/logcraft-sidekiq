# frozen_string_literal: true

require 'logcraft'
require 'sidekiq'

require_relative 'sidekiq/version'
require_relative 'sidekiq/railtie' if defined? Rails

module Logcraft
  module Sidekiq
    autoload :ErrorLogger, 'logcraft/sidekiq/error_logger'
    autoload :DeathLogger, 'logcraft/sidekiq/death_logger'
    autoload :JobContext, 'logcraft/sidekiq/job_context'
    autoload :JobLogger, 'logcraft/sidekiq/job_logger'

    def self.initialize
      initialize_logger
      ::Sidekiq.configure_server do |config|
        if config.respond_to? :[]=
          config[:job_logger] = JobLogger
        else
          config.options[:job_logger] = JobLogger
        end
        config.error_handlers.delete_if do |handler|
          (defined?(::Sidekiq::ExceptionHandler) && defined?(::Sidekiq::ExceptionHandler::Logger) && handler.is_a?(::Sidekiq::ExceptionHandler::Logger)) ||
            (handler.is_a?(Method) && handler.receiver.name == 'Sidekiq' && handler.name == :default_error_handler) ||
            (defined?(::Sidekiq::Config) && defined?(::Sidekiq::Config::ERROR_HANDLER) && (handler == ::Sidekiq::Config::ERROR_HANDLER))
        end
        config.error_handlers << ErrorLogger.new
        config.death_handlers << DeathLogger.new
      end
    end

    def self.initialize_logger
      case ::Sidekiq::VERSION.chr
      when '6'
        ::Sidekiq.logger = Logcraft.logger 'Sidekiq'
      else
        require 'ostruct' unless defined? OpenStruct # Temporary workaround for new Logcraft version not being released yet
        ::Sidekiq.configure_client { |config| config.logger = Logcraft.logger 'Sidekiq' }
        ::Sidekiq.configure_server { |config| config.logger = Logcraft.logger 'Sidekiq' }
      end
    end
  end
end
