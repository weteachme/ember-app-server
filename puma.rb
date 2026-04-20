max_threads = ENV.fetch("MAX_THREADS", 5).to_i
min_threads = ENV.fetch("MIN_THREADS", max_threads).to_i
threads min_threads, max_threads

workers ENV.fetch("WEB_CONCURRENCY", 2).to_i
port ENV.fetch("PORT", 3000)
environment ENV.fetch("RACK_ENV", "production")
