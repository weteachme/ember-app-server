mkdir -p tmp/puma
mkdir  log
mkdir  vendor

bundle install --path vendor/bundle

bundle exec puma --config puma.rb --daemon
