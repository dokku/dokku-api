FROM ruby:2.3.3
MAINTAINER Mehmet Beydogan <mehmet.beydogan@gmail.com>

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" >> /etc/apt/sources.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN apt-get install -y net-tools
RUN apt-get install -y libpq-dev
RUN apt-get install -y postgresql-server-dev-9.6

# Install gems
ENV APP_HOME /app
ENV HOME /root
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
RUN bundle install

# Upload source
COPY . $APP_HOME

# Start server
ENV PORT 3000
ENTRYPOINT ["bundler",  "exec"]