# frozen_string_literal: true

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum, this matches the default thread size of Active Record.
#
max_threads = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
min_threads = ENV.fetch("RAILS_MIN_THREADS", 5).to_i
threads max_threads, min_threads

# Specifies the `port` that Puma will listen on to receive requests, default is 3000.
#
port ENV.fetch("PUMA_PORT", 3000)

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV", "development")
# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
ram_gb= `free -h|grep Mem|cut -d ":" -f 2|cut -d "G" -f 1`.to_i + 1
num_workers= Rails.env.development? || Rails.env.test? ? 2 : [Etc.nprocessors, ram_gb].min
workers ENV.fetch("WEB_CONCURRENCY") { num_workers }
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# If you're not running on a containerized platform (like Heroku or Docker)
# you can try to detect the amount of memory you're using and only kill Puma workers
# when you're over that limit. It may allow you to go for longer periods of time
# without killing a worker however it is more error prone than rolling restarts.
# To enable measurement based worker killing put this in your config/puma.rb:
before_fork do
  require "puma_worker_killer"

  PumaWorkerKiller.config do |config|
    config.ram = ram_gb * 1024 # RAM in MB
    config.frequency = 5 # seconds
    config.percent_usage = 0.98
    config.rolling_restart_frequency = 24.hours
    config.reaper_status_logs = true # setting this to false will not log lines like:
    # PumaWorkerKiller: Consuming 54.34765625 mb with master and 2 workers.

    # config.on_calculation = -> (memory) { puts "Amount of memory used #{memory}MB" }
    config.pre_term = ->(worker) { puts "Worker #{worker.inspect} being killed" }
    config.rolling_pre_term = ->(worker) { puts "Worker #{worker.inspect} being killed by rolling restart" }
  end

  PumaWorkerKiller.start
end

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory. If you use this option
# you need to make sure to reconnect any threads in the `on_worker_boot`
# block.
#
preload_app!

# The code in the `on_worker_boot` will be called if you are using
# clustered mode by specifying a number of `workers`. After each worker
# process is booted this block will be run, if you are using `preload_app!`
# option you will want to use this block to reconnect to any threads
# or connections that may have been created at application boot, Ruby
# cannot share connections between processes.
#
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
