# frozen_string_literal: true

require 'json'
require_relative 'integration_test_worker'

RSpec.describe 'Sidekiq job running in full integration' do
  let(:logfile) { 'integration_test.log' }

  before do
    ::Sidekiq.redis { |redis| redis.flushdb }
  end

  after do
    FileUtils.rm_rf logfile
  end

  around do |spec|
    sidekiq_pid = Process.spawn 'bundle exec sidekiq -r ./spec/integration/sidekiq.rb', out: [logfile, 'w']
    spec.run
    Process.kill 'TERM', sidekiq_pid
    Process.wait sidekiq_pid
  end

  def wait_for_logs_from_finished_job
    logs = []
    120.times do
      logs = File.readlines(logfile).map do |line|
        next if line.start_with? "Signal INFO not supported"

        JSON.parse line
      end.compact
      if (logs.count { |log_line| log_line['message'] == 'Error occured in job' }) < 3
        sleep(0.5)
      else
        break
      end
    end
    logs
  end

  it 'logs all relevant events in a single-line, structured format' do
    IntegrationTestWorker.perform_async 'test', 'data'

    logs = wait_for_logs_from_finished_job

    expect(logs).to include hash_including('level' => 'INFO',
                                           'logger' => 'Sidekiq',
                                           'queue' => 'default',
                                           'worker' => 'IntegrationTestWorker',
                                           'run_count' => 1,
                                           'created_at' => /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}/,
                                           'params' => {'param1' => 'test', 'param2' => 'data'},
                                           'message' => 'IntegrationTestWorker started')
    expect(logs).to include hash_including('level' => 'INFO', 'run_count' => 1, 'message' => 'Job is executing')
    expect(logs).to include hash_including('level' => 'INFO', 'run_count' => 1, 'message' => 'IntegrationTestWorker failed')
    expect(logs).to include hash_including('level' => 'WARN', 'run_count' => 1, 'message' => 'Error occured in job')
    expect(logs).to include hash_including('level' => 'INFO', 'run_count' => 2, 'message' => 'IntegrationTestWorker started')
    expect(logs).to include hash_including('level' => 'INFO', 'run_count' => 2, 'message' => 'Job is executing')
    expect(logs).to include hash_including('level' => 'INFO', 'run_count' => 2, 'message' => 'IntegrationTestWorker failed')
    expect(logs).to include hash_including('level' => 'WARN', 'run_count' => 2, 'message' => 'Error occured in job')
    expect(logs).to include hash_including('level' => 'ERROR', 'message' => 'Error occured in job')

    warning_logs = logs.select { |log| log['level'] == 'WARN' }
    expect(warning_logs.count).to eq 2

    error_logs = logs.select { |log| log['level'] == 'ERROR' }
    expect(error_logs.count).to eq 1
  end
end
