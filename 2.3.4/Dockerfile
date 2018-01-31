FROM heroku/heroku:16-build

LABEL maintainer="jfloff@rnters.pt"

ENV WORKDIR_PATH=/app/user \
    # The versions are updated according to Heroku Ruby Buildpack
    # Check this file for RUBY version:
    # https://github.com/heroku/heroku-buildpack-ruby/blob/master/lib/language_pack/ruby_version.rb#L15
    RUBY_VERSION=2.3.4 \
    # Check this file for NODE version:
    # https://github.com/heroku/heroku-buildpack-ruby/blob/master/lib/language_pack/helpers/nodebin.rb#L14
    NODE_VERSION=6.11.1 \
    # Check this file for BUNDLER version:
    # https://github.com/heroku/heroku-buildpack-ruby/blob/master/lib/language_pack/ruby.rb#L19
    BUNDLER_VERSION=1.15.2

ENV PATH=$WORKDIR_PATH/bin:/app/heroku/ruby/bundle/ruby/$RUBY_VERSION/bin:/app/heroku/ruby/node-$NODE_VERSION/bin:/app/heroku/ruby/ruby-$RUBY_VERSION/bin/$PATH \
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
        ; \
    rm -rf /var/lib/apt/lists/* ;\
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
    # Install Bundler
    #
    mkdir -p /app/heroku/ruby/bundle/ruby/$RUBY_VERSION ;\
    gem install bundler -v $BUNDLER_VERSION --no-ri --no-rdoc ;\
    # forcebundle to use github https protocol
    bundle config github.https true ;\
    #####
    # Set startup script
    #
    chmod +x /usr/bin/init.sh ;\
    # make folder to run startup scripts
    mkdir -p $POST_RUN_SCRIPT_PATH

#####
# Install application and its gems
#
ADD . $WORKDIR_PATH
RUN set -ex ;\
    # Run bundler to cache dependencies if we have a Gemfile
    if [ -f $WORKDIR_PATH/Gemfile ]; then bundle install --jobs 4; fi

WORKDIR $WORKDIR_PATH

ENTRYPOINT ["/usr/bin/init.sh"]
