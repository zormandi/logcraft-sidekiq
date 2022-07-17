# frozen_string_literal: true

RSpec.shared_context 'Test worker' do
  let(:test_worker_perform) do
    ->(_) do
      def perform
      end
    end
  end

  before do
    TestWorkers = Module.new
    TestWorkers.const_set :TestWorker, Class.new(&test_worker_perform)
  end

  after do
    TestWorkers.send :remove_const, :TestWorker
    Object.send :remove_const, :TestWorkers
  end
end
