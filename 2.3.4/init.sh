#!/bin/bash

# just keep going if we don't have anything to install
set +e

# export secret before anything
if [ -f /etc/profile.d/secret.sh ]; then
  # add secret key base to init
  chmod +x /etc/profile.d/secret.sh
  echo "export SECRET_KEY_BASE=\"$(openssl rand -base64 32)\"" > /etc/profile.d/secret.sh
fi
source /etc/profile.d/secret.sh

# if any changes to Gemfile occur between runs (e.g. if you mounted the
# host directory in the container), it will install changes before proceeding
if [ -f $WORKDIR_PATH/Gemfile ]; then
  bundle check || bundle install --jobs 4
fi

if [ "$RAILS_ENV" == "production" ]; then
  bundle exec rake assets:precompile
fi

for SCRIPT in $POST_RUN_SCRIPT_PATH/*; do
  [ -f "$SCRIPT" ] || continue
  set -x;
  source $SCRIPT;
  { set +x; } 2>/dev/null
done

set -e

exec "$@"
