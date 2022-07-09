# frozen_string_literal: true

RSpec.describe Logcraft::Sidekiq::DeathLogger do
  let(:death_logger) { described_class.new }

  describe '#call' do
    subject(:call) { death_logger.call job, error }

    let(:job) { sidekiq_job_hash(jid: 'job ID') }
    let(:error) { StandardError.new 'error message' }

    it 'logs the error in a single message at ERROR level' do
      expect { call }.to log(message: 'error message').at_level(:error)
    end

    it 'logs the job context' do
      expect { call }.to log jid: 'job ID'
    end
  end
end
