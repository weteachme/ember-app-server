FROM ruby:4.0-slim

WORKDIR /app

RUN gem install puma sinatra

COPY app.rb .

EXPOSE 3000

CMD ["ruby", "app.rb"]