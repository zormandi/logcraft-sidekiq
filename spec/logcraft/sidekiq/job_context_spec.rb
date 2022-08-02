# frozen_string_literal: true

RSpec.describe Logcraft::Sidekiq::JobContext do
  describe '.from_job_hash' do
    subject(:job_message) { described_class.from_job_hash job_hash }

    let(:now_as_float) { Time.now.to_f }
    let(:job_hash) do
      sidekiq_job_hash jid: 'job ID',
                       queue: 'job queue',
                       worker: 'TestWorkers::TestWorker',
                       args: [1, 'customer name'],
                       created_at: now_as_float,
                       enqueued_at: now_as_float
    end
    let(:test_worker_perform) do
      ->(_) do
        def perform(customer_id, name)
        end
      end
    end

    it 'contains all relevant information about the job, including its parameters by name' do
      expect(job_message).to include jid: 'job ID',
                                     queue: 'job queue',
                                     worker: 'TestWorkers::TestWorker',
                                     params: {
                                       customer_id: 1,
                                       name: 'customer name',
                                     },
                                     created_at: Time.at(now_as_float).iso8601(3),
                                     enqueued_at: Time.at(now_as_float).iso8601(3)
    end

    it 'contains the number of times this job has run (including the current execution)' do
      expect(job_message).to include run_count: 1
    end

    context 'when the job is being retried for the first time' do
      before { job_hash['retry_count'] = 0 }

      it { is_expected.to include run_count: 2 }
    end

    context 'when the job was wrapped in an ActiveJob' do
      before do
        job_hash.merge! 'class' => 'ActiveJob',
                        'wrapped' => 'TestWorkers::TestWorker'
      end

      it 'contains the wrapped job class' do
        expect(job_message).to include worker: 'TestWorkers::TestWorker'
      end
    end

    context 'when the job is part of a batch' do
      let(:job_hash) { sidekiq_job_hash bid: 'batch ID' }

      it 'contains the batch id' do
        expect(job_message).to include bid: 'batch ID'
      end
    end

    context 'when the job has tags' do
      let(:job_hash) { sidekiq_job_hash tags: ['a-tag', 'b-tag'] }

      it 'contains the tags' do
        expect(job_message).to include tags: ['a-tag', 'b-tag']
      end
    end

    context 'when the job has "current attributes"' do
      let(:job_hash) { sidekiq_job_hash cattr: {'some' => 'data'} }

      it 'contains the tags' do
        expect(job_message).to include cattr: {'some' => 'data'}
      end
    end

    context "when the job's parameters are not all required" do
      let(:test_worker_perform) do
        ->(_) do
          def perform(user_id, *args, last_arg)
          end
        end
      end
      let(:job_hash) { sidekiq_job_hash args: [1, 'customer name', 2, 'more args', 3] }

      it 'contains the params' do
        expect(job_message).to include params: {
                                         user_id: 1,
                                         args: ['customer name', 2, 'more args'],
                                         last_arg: 3
                                       }
      end

      context 'when called with just enough arguments' do
        let(:job_hash) { sidekiq_job_hash args: [1, 2] }

        it 'contains the rest arg as empty' do
          expect(job_message).to include params: {
                                           user_id: 1,
                                           args: [],
                                           last_arg: 2
                                         }
        end
      end

      context 'when called with just too few arguments' do
        let(:job_hash) { sidekiq_job_hash args: [1] }

        it 'raises no error but no other behavior is defined as the call is erroneous' do
          expect { job_message }.not_to raise_error
        end
      end
    end

    context "when Sidekiq's thread id is set on the current thread" do
      before { Thread.current['sidekiq_tid'] = '[worker thread id]' }

      it 'contains the thread id of the worker' do
        expect(job_message).to include tid: '[worker thread id]'
      end
    end

    context "when Sidekiq's thread id is not set on the current thread" do
      before { Thread.current['sidekiq_tid'] = nil }

      it "contains the currently running thread's id, calculated the same way Sidekiq does it" do
        expect(job_message).to include tid: (Thread.current.object_id ^ ::Process.pid).to_s(36)
      end
    end

    context 'when the job hash is empty' do
      let(:job_hash) { nil }

      it 'returns an empty Hash' do
        expect(job_message).to eq({})
      end
    end
  end
end
