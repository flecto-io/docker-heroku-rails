#!/bin/bash

# just keep going if we don't have anything to install
set +e

# export secret before anything
source /etc/profile.d/secret.sh

# if any changes to Gemfile occur between runs (e.g. if you mounted the
# host directory in the container), it will install changes before proceeding
bundle check || bundle install
# we do not do any db:migrate since that should be in the Procfile

if [ "$RAILS_ENV" == "production" ]; then
  bundle exec rake assets:precompile
fi

for SCRIPT in $POST_RUN_SCRIPT_PATH/*; do
  set -x;
  source $SCRIPT;
  { set +x; } 2>/dev/null
done

set -e

exec "$@"
