FROM ruby:2.7.2-alpine

RUN apk update; \
    apk add --no-cache --virtual .build-deps build-base linux-headers \
      neovim \
      git \
      tzdata \
      postgresql-dev \
      postgresql-client \
      bash \
      yarn \
      less \
      imagemagick

ENV BUNDLE_PATH /gems
ENV GEM_PATH /gems
ENV GEM_HOME /gems

ENV APP_PATH /app

ENV PATH /gems/bin:$PATH

WORKDIR $APP_PATH
COPY Gemfile $APP_PATH
COPY Gemfile.lock $APP_PATH

COPY . $APP_PATH

RUN gem update --system
RUN gem install bundler:2.2.16
RUN git config --global http.sslVerify false
RUN bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3

RUN yarn install --check-files

EXPOSE 3000:3000

CMD ['bundle', 'exec', 'rails', 'server', '-b', '0.0.0.0', '-p', '3000']
