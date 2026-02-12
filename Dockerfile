# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.4.8
FROM docker.io/library/ruby:$RUBY_VERSION-slim

# Rails app lives here
WORKDIR /rails

# Install packages needed for development
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  build-essential \
  curl \
  default-libmysqlclient-dev \
  default-mysql-client \
  git \
  libjemalloc2 \
  libyaml-dev \
  pkg-config \
  && ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so \
  && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install Node.js (required for Vite + React)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
  apt-get install --no-install-recommends -y nodejs && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Environment variables
ENV LANG=C.UTF-8 \
  TZ=Asia/Tokyo \
  RAILS_ENV=development \
  BUNDLE_PATH="/usr/local/bundle" \
  LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# Install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler foreman && \
  bundle install && \
  rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache

# Install npm packages
COPY package.json package-lock.json ./
RUN npm ci

# Copy application code
COPY . .

EXPOSE 3000 3036
CMD ["./bin/dev"]
