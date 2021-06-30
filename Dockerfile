FROM ruby:3.0.1

LABEL Name=degreeofconnections_be Version=1.0.0

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
WORKDIR /app
ADD . /app
ADD Gemfile /Gemfile
ADD Gemfile.lock /Gemfile.lock

RUN gem install bundler -v 2.2.21
RUN bundle install

# ENTRYPOINT ["/usr/bin/"]

CMD ["rails", "server"]
