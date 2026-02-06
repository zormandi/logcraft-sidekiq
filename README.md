# Logcraft::Sidekiq

[![Build Status](https://github.com/zormandi/logcraft-sidekiq/actions/workflows/main.yml/badge.svg)](https://github.com/zormandi/logcraft-sidekiq/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/logcraft-sidekiq.svg)](https://badge.fury.io/rb/logcraft-sidekiq)

Logcraft::Sidekiq is a structured logging solution for [Sidekiq](https://github.com/mperham/sidekiq), using
zthe [Logcraft](https://github.com/zormandi/logcraft) gem. It supports (and is tested with) Sidekiq 6, 7 and 8.

## Installation

### Rails

Add this line to your application's Gemfile:

```ruby
gem 'logcraft-sidekiq'
```

### Non-Rails applications

Add this line to your application's Gemfile:

```ruby
gem 'logcraft-sidekiq'
```

and call

```ruby
Logcraft::Sidekiq.initialize
```

any time during your application's startup.

## Usage

### Structured logging

Logcraft::Sidekiq configures the `Sidekiq.logger` to be an instance of a Logcraft logger by the name of `Sidekiq`,
providing all the structured logging features that Logcraft provides, like logging complex messages, errors, etc.
The logger uses the same default log level that was configured for Logcraft.

### Job logging

Logcraft::Sidekiq logs relevant information about every job run in a compact, structured format.

* It emits two log messages per job run; one when the job is started and another one when the job is finished
  (successfully or unsuccessfully).
* It measures the time it took to execute the job and appends the benchmark information to the final log message.
* It adds all basic information about the job (worker, queue, JID, BID, tags, created_at, enqueued_at, run_count) to
  the log context so all log messages emitted during the execution of the job will contain this information.
* It also adds all of the job's parameters (by name) to the log context under the `params` key, which means that all 
  log messages emitted during the execution of the job will contain this information as well.

```ruby
class TestWorker
  include Sidekiq::Worker

  def perform(customer_id)
    logger.warn 'Customer not found'
  end
end

TestWorker.perform_async 42

#=> {"timestamp":"2022-07-17T18:23:36.320+02:00","level":"INFO","logger":"Sidekiq","hostname":"MacbookPro.local","pid":20740,"jid":"aad6c56ece22b115fb91821e","queue":"default","worker":"TestWorker","created_at":"2022-07-17T18:23:35.932+02:00","enqueued_at":"2022-07-17T18:23:35.932+02:00","run_count":1,"tid":"hrg","params":{"customer_id":42},"message":"TestWorker started"}
#=> {"timestamp":"2022-07-17T18:23:36.320+02:00","level":"WARN","logger":"Sidekiq","hostname":"MacbookPro.local","pid":20740,"jid":"aad6c56ece22b115fb91821e","queue":"default","worker":"TestWorker","created_at":"2022-07-17T18:23:35.932+02:00","enqueued_at":"2022-07-17T18:23:35.932+02:00","run_count":1,"tid":"hrg","params":{"customer_id":42},"message":"Customer not found"}
#=> {"timestamp":"2022-07-17T18:23:36.324+02:00","level":"INFO","logger":"Sidekiq","hostname":"MacbookPro.local","pid":20740,"jid":"aad6c56ece22b115fb91821e","queue":"default","worker":"TestWorker","created_at":"2022-07-17T18:23:35.932+02:00","enqueued_at":"2022-07-17T18:23:35.932+02:00","run_count":1,"tid":"hrg","params":{"customer_id":42},"duration":4,"duration_sec":0.004,"message":"TestWorker finished"}
```

### Error logging

Logcraft::Sidekiq sets up an error and death handler for your jobs automatically, replacing the built-in error handler.
If a job finishes with an error then it is logged at WARN level (assuming it will be retried) and death events are
logged at ERROR level. Both messages are single line events, containing all relevant information about the error.

### Job-specific log level

Sidekiq supports setting a log level per worker but Logcraft::Sidekiq ignores this feature. Supporting it would 
lead to a lot of complexity in the code and frankly, I'm not convinced it's worth it. If you really need and
use this feature then please reach out to me. In the meantime, the workaround is quite simple:

```ruby
# Instead of this:
class TestWorker
  include Sidekiq::Worker
  sidekiq_options log_level: :warn
end

# Do this:
class TestWorker
  include Sidekiq::Worker

  def perform
    logger = Logcraft.logger self, :warn
    # ...
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zormandi/logcraft-sidekiq. This project is
intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to
the [code of conduct](https://github.com/zormandi/logcraft-sidekiq/blob/master/CODE_OF_CONDUCT.md).

## Disclaimer

Logcraft::Sidekiq is highly opinionated software and does in no way aim or claim to be useful for everyone.
Use at your own discretion.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Logcraft::Sidekiq project's codebases, issue trackers, chat rooms and mailing lists is
expected to follow the [code of conduct](https://github.com/zormandi/logcraft-sidekiq/blob/master/CODE_OF_CONDUCT.md).
