# frozen_string_literal: true

require 'logcraft/sidekiq'
require 'logcraft/rspec'

require_relative 'support/job_helpers'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include JobHelpers

  config.before :all do
    ::Sidekiq.logger = Logcraft.logger 'Sidekiq'
  end
end
