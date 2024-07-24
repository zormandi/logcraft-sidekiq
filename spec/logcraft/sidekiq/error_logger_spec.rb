# frozen_string_literal: true

RSpec.describe Logcraft::Sidekiq::ErrorLogger do
  let(:error_logger) { described_class.new }

  describe '#call' do
    subject(:call) { error_logger.call error, context }

    let(:error) { StandardError.new 'error message' }
    let(:context) { {job: sidekiq_job_hash(jid: 'job ID')} }

    it 'logs the error in a single message at WARN level' do
      expect { call }.to log(message: 'error message').at_level(:warn)
    end

    it 'logs the job context' do
      expect { call }.to log jid: 'job ID'
    end

    context 'when called with a third argument starting from Sidekiq 8' do
      subject(:call) { error_logger.call error, context, config }
      let(:config) { double }

      it 'accepts the third argument' do
        expect { call }.not_to raise_error
      end
    end
  end
end
