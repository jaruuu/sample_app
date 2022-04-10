FROM ruby:3.0.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /myapp
WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock

# M1 Mac で出る nokogiri のエラー対応
RUN gem install bundler -v 2.1.4
RUN bundle config set force_ruby_platform true

RUN bundle _2.1.4_ install
ADD . /myapp
