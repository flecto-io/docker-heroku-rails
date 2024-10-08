FROM heroku/heroku:24-build
LABEL maintainer="jfloff@flecto.io"

USER root
ENV HOME=/app \
    HEROKU_HOME=/heroku \
    HEROKU_BUILDPACK_VERSION=24 \
    # The versions are updated according to Heroku Ruby Buildpack
    # Check this file for RUBY version:
    # https://github.com/heroku/heroku-buildpack-ruby/blob/main/lib/language_pack/ruby_version.rb#L16
    RUBY_VERSION=3.3.5 \
    # Check this file for NODE version:
    # https://github.com/heroku/heroku-buildpack-ruby/blob/main/lib/language_pack/helpers/nodebin.rb#L5
    NODE_VERSION=20.9.0 \
    # Check this file for YARN version:
    # https://github.com/heroku/heroku-buildpack-ruby/blob/main/lib/language_pack/helpers/nodebin.rb#L13
    YARN_VERSION=1.22.19

ENV PATH=$HOME/bin:$HEROKU_HOME/ruby/bundle/ruby/$RUBY_VERSION/bin:$HEROKU_HOME/ruby/ruby-$RUBY_VERSION/bin:$HEROKU_HOME/ruby/node-$NODE_VERSION/bin:$HEROKU_HOME/ruby/yarn-$YARN_VERSION/bin:${PATH} \
    # so no interactions happen while installing packages
    DEBIAN_FRONTEND=noninteractive \
    # Bundler variables
    GEM_PATH=$HEROKU_HOME/ruby/bundle/ruby/$RUBY_VERSION \
    GEM_HOME=$HEROKU_HOME/ruby/bundle/ruby/$RUBY_VERSION \
    BUNDLE_APP_CONFIG=$HEROKU_HOME/ruby/.bundle/config

# set the locale of the application
# this is useful for rails console handling UTF8 characters
ARG LOCALE="en_US.UTF-8"
ENV LANG=$LOCALE \
    LC_COLLATE=$LOCALE \
    LC_CTYPE=$LOCALE \
    LC_MESSAGES=$LOCALE \
    LC_MONETARY=$LOCALE \
    LC_NUMERIC=$LOCALE \
    LC_TIME=$LOCALE \
    LC_ALL=$LOCALE

# Copy init script
COPY ./init.sh /usr/bin/init.sh

RUN set -ex ;\
    export ARCH=$(dpkg --print-architecture) ;\
    mkdir -p $HOME ;\
    #------------
    # Remove existing ruby
    #------------
    dpkg --purge --force-depends ruby ;\
    #------------
    # Install extra dependencies
    #------------
    apt-get update && apt-get install -y --no-install-recommends \
        tzdata \
        tree \
        # needed to download https gems
        libssl-dev \
        # for rails rspec
        busybox \
        # utils
        inetutils-ping \
        vim \
        ; \
    rm -rf /var/lib/apt/lists/* ;\
    #------------
    # Install Ruby
    #------------
    # url ref: https://github.com/heroku/heroku-buildpack-ruby/blob/main/bin/support/download_ruby#L32
    mkdir -p $HEROKU_HOME/ruby/ruby-$RUBY_VERSION ;\
    curl -sL --retry 3 https://heroku-buildpack-ruby.s3.amazonaws.com/heroku-$HEROKU_BUILDPACK_VERSION/$ARCH/ruby-$RUBY_VERSION.tgz | tar xz -C $HEROKU_HOME/ruby/ruby-$RUBY_VERSION ;\
    #------------
    # Install Node
    #------------
    # node archictures has different matches -- this just covers our 2 platforms (arm64 and amd64)
    case "$ARCH" in \
        amd64) NODE_ARCH='x64' ;;\
        *) NODE_ARCH="$ARCH" ;;\
    esac ;\
    curl -sL --retry 3 https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz | tar xJ -C $HEROKU_HOME/ruby/ ;\
    mv $HEROKU_HOME/ruby/node-v$NODE_VERSION-linux-$NODE_ARCH $HEROKU_HOME/ruby/node-$NODE_VERSION ;\
    #------------
    # Install Yarn
    #------------
    curl -sL --retry 3 https://s3.amazonaws.com/heroku-nodebin/yarn/release/yarn-v$YARN_VERSION.tar.gz | tar xz -C $HEROKU_HOME/ruby/ ;\
    mv $HEROKU_HOME/ruby/yarn-v$YARN_VERSION $HEROKU_HOME/ruby/yarn-$YARN_VERSION ;\
    #------------
    # Set startup script
    #------------
    chmod +x /usr/bin/init.sh

#------------
# Install application and its gems
#------------
WORKDIR $HOME
ONBUILD ADD . $HOME
ONBUILD RUN set -ex ;\
    # force bundle to use github https protocol
    bundle config github.https true
    # avoid installing gems here so we give a chance for child images to install any dependency
    # eg. SQLite3 extension

ENTRYPOINT ["/usr/bin/init.sh"]
