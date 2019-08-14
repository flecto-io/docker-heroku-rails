FROM heroku/heroku:18-build

LABEL maintainer="jfloff@rnters.com"

ENV WORKDIR_PATH=/app/user \
    # The versions are updated according to Heroku Ruby Buildpack
    # Check this file for RUBY version:
    # https://github.com/heroku/heroku-buildpack-ruby/blob/master/lib/language_pack/ruby_version.rb#L15
    RUBY_VERSION=2.3.4 \
    # Check this file for NODE version:
    # https://github.com/heroku/heroku-buildpack-ruby/blob/master/lib/language_pack/helpers/nodebin.rb#L5
    NODE_VERSION=6.11.1

ENV PATH=$WORKDIR_PATH/bin:/app/heroku/ruby/bundle/ruby/$RUBY_VERSION/bin:/app/heroku/ruby/node-$NODE_VERSION/bin:/app/heroku/ruby/ruby-$RUBY_VERSION/bin/:${PATH} \
    # so no interactions happen while installing packages
    DEBIAN_FRONTEND=noninteractive \
    # Bundler variables
    GEM_PATH=/app/heroku/ruby/bundle/ruby/$RUBY_VERSION \
    GEM_HOME=/app/heroku/ruby/bundle/ruby/$RUBY_VERSION \
    BUNDLE_APP_CONFIG=/app/heroku/ruby/.bundle/config \
    POST_RUN_SCRIPT_PATH=/app/.post-run.d

# Copy init script
COPY ./init.sh /usr/bin/init.sh

RUN set -ex ;\
    mkdir -p $WORKDIR_PATH ;\
    #####
    # Install extra dependencies
    #
    apt-get update && apt-get install -y --no-install-recommends \
        tzdata \
        tree \
        # for rails rspec
        busybox \
        # utils
        inetutils-ping \
        vim \
        ; \
    rm -rf /var/lib/apt/lists/* ;\
    # fix bug when launching rails console
    ln -s /lib/x86_64-linux-gnu/libreadline.so.7 /lib/x86_64-linux-gnu/libreadline.so.6 ;\
    #####
    # Install Ruby
    #
    mkdir -p /app/heroku/ruby/ruby-$RUBY_VERSION ;\
    curl -sL --retry 3 https://heroku-buildpack-ruby.s3.amazonaws.com/heroku-16/ruby-$RUBY_VERSION.tgz | tar xz -C /app/heroku/ruby/ruby-$RUBY_VERSION ;\
    #####
    # Install Node
    #
    curl -sL --retry 3 https://s3pository.heroku.com/node/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz | tar xz -C /app/heroku/ruby/ ;\
    mv /app/heroku/ruby/node-v$NODE_VERSION-linux-x64 /app/heroku/ruby/node-$NODE_VERSION ;\
    #####
    # Set startup script
    #
    chmod +x /usr/bin/init.sh ;\
    # make folder to run startup scripts
    mkdir -p $POST_RUN_SCRIPT_PATH

#####
# Install application and its gems
#
WORKDIR $WORKDIR_PATH
ONBUILD ADD . $WORKDIR_PATH
ONBUILD RUN set -ex ;\
    # TODO @jfloff : won't be needed when we upgrade to Rails 5
    # install bundler packed with Gemfile if we have that information in the Gemfile.lock
    # ref: https://bundler.io/blog/2019/01/04/an-update-on-the-bundler-2-release.html
    if [ -f Gemfile.lock ]; then GEMFILE_LOCK_BUNDLE_VERSION=$(awk '/BUNDLED WITH/{getline; print}' Gemfile.lock) ; else GEMFILE_LOCK_BUNDLE_VERSION="" ; fi ;\
    if [ -z "$GEMFILE_LOCK_BUNDLE_VERSION" ]; then BUNDLER_INSTALL_VERSION_FLAG="" ; else BUNDLER_INSTALL_VERSION_FLAG="-v $GEMFILE_LOCK_BUNDLE_VERSION" ; fi ;\
    gem install --no-ri --no-rdoc bundler $BUNDLER_INSTALL_VERSION_FLAG ;\
    # force bundle to use github https protocol
    bundle config github.https true


ENTRYPOINT ["/usr/bin/init.sh"]
