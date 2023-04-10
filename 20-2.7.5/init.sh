#!/bin/bash

# just keep going if we don't have anything to install
set +e

# set BUNDLER_VERSION env variable in case we need it
if [ -f Gemfile.lock ]; then
  GEMFILE_LOCK_BUNDLE_VERSION=$(awk '/BUNDLED WITH/{getline; print}' Gemfile.lock)
fi

  # add secret key base to init
if [ ! -f /etc/profile.d/secret.sh ]; then
  echo "export SECRET_KEY_BASE=\"$(openssl rand -base64 32)\"" > /etc/profile.d/secret.sh
  chmod +x /etc/profile.d/secret.sh
fi
# export secret before anything
source /etc/profile.d/secret.sh

# if any changes to Gemfile occur between runs (e.g. if you mounted the
# host directory in the container), it will install changes before proceeding
if [ -f Gemfile ]; then
  bundle check || bundle install --jobs 4 --retry 3
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
