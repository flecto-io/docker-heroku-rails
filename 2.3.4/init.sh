#!/bin/bash

# if any changes to Gemfile occur between runs (e.g. if you mounted the
# host directory in the container), it will install changes before proceeding
bundle check || bundle install

# Runs pending migrations if any pending
# if setup fails just keep going and we will see an error in the future
set +e ; rake db:migrate; rake db:seed ; set -e

if [ "$RAILS_ENV" == "production" ]; then
  bundle exec rake assets:precompile
fi

for SCRIPT in /app/.post-run/*; do
  set -x;
  source $SCRIPT;
  { set +x; } 2>/dev/null
done

exec "$@"
