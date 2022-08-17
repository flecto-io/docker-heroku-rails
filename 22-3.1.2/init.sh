#!/bin/bash

# just keep going if we don't have anything to install
set +e

# set BUNDLER_VERSION env variable in case we need it
if [ -f Gemfile.lock ]; then
  GEMFILE_LOCK_BUNDLE_VERSION=$(awk '/BUNDLED WITH/{getline; print}' Gemfile.lock)
fi

# if any changes to Gemfile occur between runs (e.g. if you mounted the
# host directory in the container), it will install changes before proceeding
if [ -f Gemfile ]; then
  bundle check || bundle install --jobs 4
fi

if [ "$RAILS_ENV" == "production" ]; then
  bundle exec rake assets:precompile
fi

if test -f "$HOME/.profile"; then
  set -x;
  source $HOME/.profile;
  { set +x; } 2>/dev/null
fi

set -e

exec "$@"
