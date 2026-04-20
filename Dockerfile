FROM ruby:4.0-slim

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libyaml-dev pkg-config libjemalloc2 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN gem install bundler -v 4.0.7
# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf /usr/local/bundle/cache

COPY app.rb config.ru puma.rb ./

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "puma.rb"]
