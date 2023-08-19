# frozen_string_literal: true

require 'logcraft/sidekiq'
require 'logcraft/rspec'

require_relative 'support/job_helpers'
require_relative 'support/test_worker'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include JobHelpers
  config.include_context 'Test worker'

  config.before :all do
    Logcraft::Sidekiq.initialize_logger
  end
end
