# frozen_string_literal: true

module JobHelpers
  def sidekiq_job_hash(jid: 'job id',
                       bid: nil,
                       tags: nil,
                       queue: 'job queue',
                       worker: 'TestWorkers::TestWorker',
                       args: [],
                       cattr: nil,
                       created_at: Time.now.to_f,
                       enqueued_at: Time.now.to_f)
    {
      'jid' => jid,
      'bid' => bid,
      'tags' => tags,
      'queue' => queue,
      'class' => worker,
      'args' => args,
      'cattr' => cattr,
      'created_at' => created_at,
      'enqueued_at' => enqueued_at
    }.compact
  end
end
