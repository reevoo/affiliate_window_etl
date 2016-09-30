FROM quay.io/assemblyline/ruby:2.3.1

WORKDIR /usr/src

COPY Gemfile* ./
COPY *.gemspec ./
COPY lib/affiliate_window/etl/version.rb ./lib/affiliate_window/etl/

RUN bundle install -j4 -r3

COPY . .
