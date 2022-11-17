FROM heroku/heroku:20-build
LABEL maintainer="jfloff@rnters.com"

ENV HOME=/app \
    HEROKU_HOME=/heroku \
    HEROKU_BUILDPACK_VERSION=20 \
    # The versions are updated according to Heroku Ruby Buildpack
    # Check this file for RUBY version:
    # https://github.com/heroku/heroku-buildpack-ruby/blob/master/lib/language_pack/ruby_version.rb#L16
    RUBY_VERSION=2.7.5 \
    # Check this file for NODE version:
    # https://github.com/heroku/heroku-buildpack-ruby/blob/master/lib/language_pack/helpers/nodebin.rb#L5
    NODE_VERSION=16.13.1 \
    # Check this file for YARN version:
    # https://github.com/heroku/heroku-buildpack-ruby/blob/master/lib/language_pack/helpers/nodebin.rb#L13
    YARN_VERSION=1.22.17

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
    mkdir -p $HOME ;\
    #------------
    # Remove existing ruby
    #------------
    apt-get purge ruby -y ;\
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
    # fix bug when launching rails console
    ln -s /lib/x86_64-linux-gnu/libreadline.so.7 /lib/x86_64-linux-gnu/libreadline.so.6 ;\
    #------------
    # Install Ruby
    #------------
    mkdir -p $HEROKU_HOME/ruby/ruby-$RUBY_VERSION ;\
    curl -sL --retry 3 https://heroku-buildpack-ruby.s3.amazonaws.com/heroku-$HEROKU_BUILDPACK_VERSION/ruby-$RUBY_VERSION.tgz | tar xz -C $HEROKU_HOME/ruby/ruby-$RUBY_VERSION ;\
    #------------
    # Install Node
    #------------
    curl -sL --retry 3 https://s3.amazonaws.com/heroku-nodebin/node/release/linux-x64/node-v$NODE_VERSION-linux-x64.tar.gz | tar xz -C $HEROKU_HOME/ruby/ ;\
    mv $HEROKU_HOME/ruby/node-v$NODE_VERSION-linux-x64 $HEROKU_HOME/ruby/node-$NODE_VERSION ;\
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
    # TODO @jfloff : won't be needed when we upgrade to Rails 5
    # install bundler packed with Gemfile if we have that information in the Gemfile.lock
    # ref: https://bundler.io/blog/2019/01/04/an-update-on-the-bundler-2-release.html
    if [ -f Gemfile.lock ]; then GEMFILE_LOCK_BUNDLE_VERSION=$(awk '/BUNDLED WITH/{getline; print}' Gemfile.lock) ; else GEMFILE_LOCK_BUNDLE_VERSION="" ; fi ;\
    if [ -z "$GEMFILE_LOCK_BUNDLE_VERSION" ]; then BUNDLER_INSTALL_VERSION_FLAG="" ; else BUNDLER_INSTALL_VERSION_FLAG="-v $GEMFILE_LOCK_BUNDLE_VERSION" ; fi ;\
    gem install --no-document bundler $BUNDLER_INSTALL_VERSION_FLAG ;\
    # force bundle to use github https protocol
    bundle config github.https true
    # avoid installing gems here so we give a chance for child images to install any dependency
    # eg. SQLite3 extension


ENTRYPOINT ["/usr/bin/init.sh"]
