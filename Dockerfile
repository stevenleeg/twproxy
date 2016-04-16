FROM ruby:2.3

EXPOSE 4567
ENV PORT 4567
COPY Gemfile /usr/src/app/Gemfile
WORKDIR /usr/src/app
RUN bundle install

COPY . /usr/src/app
RUN gem build ./twproxy.gemspec
RUN gem install ./twproxy-0.0.1.gem

CMD ["./bin/twproxy", "-b", "0.0.0.0", "-d", "http://twiki:8080"]

