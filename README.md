# Heroku Rails Docker Image

Docker container for Rails based on the new Heroku-16 base image.

### Tags available

* `latest`,`2.3.4` *[(2.3.4/Dockerfile)](2.3.4/Dockerfile)*

_We try to stay up-to-date with the new supported Heroku images. If you see any new one on [this page](https://devcenter.heroku.com/articles/ruby-support#supported-runtimes) feel free to open a PR!_

### Motivation
The Heroku base images for ruby got [deprecated](https://github.com/heroku/docker-ruby) in favor of a more [build-your-own Dockerfile strategy](https://devcenter.heroku.com/articles/local-development-with-docker-compose). But I still feel that a base image for Rails serves its purposes. There is no point for each developer to replicate much of the instructions I've used here. The more automation the better amirite?

### Usage
The root folder for your Rails project must have a `Gemfile` and `Gemfile.lock` file. Then build a Dockerfile for your project with this image as base, and with other project-specific instructions (for example add some *post-run scripts*, see below):
```docker
FROM jfloff/docker-heroku-rails:latest
# example of post-run script
RUN echo "rake db:seed" > $POST_RUN_SCRIPT_PATH/seed.sh
```

Then you can either run it with standard Docker `docker run --rm -ti your-project` or, more commonly from a Docker Compose based development `$ docker-compose up web`.

_For more details regarding local development with docker read this [Heroku article](https://devcenter.heroku.com/articles/local-development-with-docker-compose)_

### Post-run script
This container comes with a [post-run script](init.sh) that:
- Checks and install any missing gem.
- Checks if there is any pending migrations and migrates them
- Precompile your assets if you are in production mode (checks `$RAILS_ENV` value).
- **Run your own run other post-run scripts**. Just add them to `/app/.post-run.d/` folder (you can also use the env varaible `$POST_RUN_SCRIPT_PATH`, which has the script path).

Subsequent runs will use cached changes. This is useful to avoid you from (1) having to rebuild the images each time there is a change on your Gemfile, (2) from having to run a shell just to deploy pending migrations, and (3) to precompile assets if you want to test production mode.



### License

MIT (see LICENSE file)
