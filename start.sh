mkdir -p tmp/puma
mkdir -p log
mkdir -p vendor

bundle install --path vendor/bundle

bundle exec puma --config puma.rb --daemon
