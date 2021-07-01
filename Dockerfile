FROM ruby:3.0.1

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
WORKDIR /app
ADD . /app
ADD Gemfile /Gemfile
ADD Gemfile.lock /Gemfile.lock
EXPOSE 3000
RUN gem install bundler -v 2.2.21
RUN bundle install

CMD ["rails", "server"]
