# frozen_string_literal: true

RSpec.shared_context 'Test worker' do
  let(:test_worker_perform) do
    ->(_) do
      def perform
      end
    end
  end

  before do
    stub_const 'TestWorkers::TestWorker', Class.new(&test_worker_perform)
  end
end
