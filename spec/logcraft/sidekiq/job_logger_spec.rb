# frozen_string_literal: true

RSpec.describe Logcraft::Sidekiq::JobLogger do
  subject(:job_logger) { described_class.new }
  let(:job_hash) { sidekiq_job_hash jid: 'job ID', worker: 'TestWorkers::TestWorker' }

  describe '#call' do
    it 'yields the block it was called with' do
      expect { |block| job_logger.call(job_hash, :queue, &block) }.to yield_control
    end

    it 'logs a start message including the job context' do
      expect { job_logger.call(job_hash, :queue) {} }.to log(message: 'TestWorkers::TestWorker started', jid: 'job ID').at_level(:info)
    end

    it 'logs the start message before dispatching the job' do
      job_logger.call(job_hash, :queue) do
        log_output_is_expected.to include_log_message message: 'TestWorkers::TestWorker started'
      end
    end

    it 'logs a finish message with job context and timing' do
      allow(::Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC, :millisecond).and_return 2373390260,
                                                                                                          2373390403
      expect { job_logger.call(job_hash, :queue) {} }.to log(message: 'TestWorkers::TestWorker finished',
                                                             jid: 'job ID',
                                                             duration: 143,
                                                             duration_sec: 0.143).at_level(:info)
    end

    context 'when the job itself logs a message' do
      let(:call_with_logging) { job_logger.call(job_hash, :queue) { Sidekiq.logger.info 'Message during processing' } }

      it 'includes the context information of the job' do
        expect { call_with_logging }.to log(message: 'Message during processing', jid: 'job ID').at_level(:info)
      end
    end

    context 'when something is logged after the job is finished' do
      it "does not include the - already executed - job's context information" do
        job_logger.call(job_hash, :queue) {}
        expect { Sidekiq.logger.info 'Message after processing' }.not_to log message: 'Message after processing',
                                                                             jid: 'job ID'
      end
    end

    context 'when there is an error processing the job' do
      let(:call_with_exception) { job_logger.call(job_hash, :queue) { raise Exception } }

      it 'lets the error through and logs a failure message with job context and timing' do
        allow(::Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC, :millisecond).and_return 2373390260,
                                                                                                            2373390403
        expect { call_with_exception }.to raise_error(Exception).and log(message: 'TestWorkers::TestWorker failed',
                                                                         jid: 'job ID',
                                                                         duration: 143,
                                                                         duration_sec: 0.143).at_level(:info)
      end
    end

    if defined? ::Sidekiq::Config
      context 'when the job logger is instantiated with a Sidekiq::Config instead of a Logger' do
        subject(:job_logger) { described_class.new config }
        let(:config) { ::Sidekiq::Config.new }

        before do
          config.logger = ::Sidekiq.logger
        end

        it 'logs a start message including the job context' do
          expect { job_logger.call(job_hash, :queue) {} }.to log message: 'TestWorkers::TestWorker started', jid: 'job ID'
        end
      end
    end
  end

  describe '#prepare' do
    it 'yields the block that was passed' do
      expect { |block| job_logger.prepare job_hash, &block }.to yield_control
    end
  end
end
