ARG VERSION
FROM ruby:${VERSION}

WORKDIR /workspace
RUN mkdir -p lib/crockford32
COPY Gemfile Gemfile.lock crockford32.gemspec ./
COPY lib/crockford32/version.rb ./lib/crockford32/
RUN gem install bundler:2.3.3 && bundle install
