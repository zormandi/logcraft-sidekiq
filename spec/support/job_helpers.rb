# frozen_string_literal: true

module TestWorkers
  class TestWorker
    def perform(customer_id, name) end
  end
end

module JobHelpers
  def sidekiq_job_hash(jid: 'job id',
                       bid: nil,
                       tags: nil,
                       queue: 'job queue',
                       worker: 'TestWorkers::TestWorker',
                       args: [],
                       created_at: Time.now,
                       enqueued_at: Time.now)
    {
      'jid' => jid,
      'bid' => bid,
      'tags' => tags,
      'queue' => queue,
      'class' => worker,
      'args' => args,
      'created_at' => created_at,
      'enqueued_at' => enqueued_at
    }.compact
  end
end
