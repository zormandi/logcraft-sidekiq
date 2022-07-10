class IntegrationTestWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1
  sidekiq_retry_in { 1 }

  def perform(param1, param2)
    logger.info 'Job is executing'
    raise StandardError, 'Error occured in job'
  end
end
