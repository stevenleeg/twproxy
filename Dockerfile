FROM ruby:2.3

EXPOSE 4567
ENV PORT 4567
COPY . /usr/src/app
WORKDIR /usr/src/app
RUN bundle install

CMD ["ruby", "server.rb"]

