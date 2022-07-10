require 'logcraft/sidekiq'
require_relative 'integration_test_worker'

Logcraft.initialize
Logcraft::Sidekiq.initialize
