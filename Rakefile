# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

namespace :spec do
  desc 'Run RSpec unit tests'
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.exclude_pattern = 'spec/integration/*_spec.rb'
  end

  desc 'Run RSpec integration tests'
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = 'spec/integration/*_spec.rb'
  end
end

desc 'Run all RSpec examples'
RSpec::Core::RakeTask.new(:spec)

task default: :spec
