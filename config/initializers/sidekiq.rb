require 'sidekiq'
require 'sidekiq/scheduler'

redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')

Sidekiq.configure_server do |config|
  config.on(:startup) do
    Sidekiq::Scheduler.enabled = true
    Sidekiq::Scheduler.dynamic = true
  end

  config.redis = {
    url: redis_url,
    size: 10,
    pool_timeout: 30
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_url
  }
end
