# frozen_string_literal: true

require 'rails/railtie'

module Logcraft
  module Sidekiq
    class Railtie < ::Rails::Railtie
      initializer 'logcraft-sidekiq.initialize' do |app|
        Logcraft::Sidekiq.initialize
      end
    end
  end
end
