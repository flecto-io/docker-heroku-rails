# Heroku Rails Docker Image

Docker container for Rails based on the Heroku base images.

### Tags available

* `20-2.6.6` *[(20-2.6.6/Dockerfile)](20-2.6.6/Dockerfile)*
* `20-2.6.8` *[(20-2.6.8/Dockerfile)](20-2.6.8/Dockerfile)*
* `20-2.6.9` *[(20-2.6.9/Dockerfile)](20-2.6.9/Dockerfile)*
* `20-2.6.10` *[(20-2.6.10/Dockerfile)](20-2.6.10/Dockerfile)*
* `20-2.7.4` *[(20-2.7.4/Dockerfile)](20-2.7.4/Dockerfile)*
* `20-2.7.5` *[(20-2.7.5/Dockerfile)](20-2.7.5/Dockerfile)*
* `20-2.7.6` *[(20-2.7.6/Dockerfile)](20-2.7.6/Dockerfile)*
* `20-2.7.7` *[(20-2.7.7/Dockerfile)](20-2.7.7/Dockerfile)*
* `20-2.7.8` *[(20-2.7.8/Dockerfile)](20-2.7.8/Dockerfile)*
* `20-3.0.2` *[(20-3.0.2/Dockerfile)](20-3.0.2/Dockerfile)*
* `20-3.0.3` *[(20-3.0.3/Dockerfile)](20-3.0.3/Dockerfile)*
* `20-3.1.2` *[(20-3.1.2/Dockerfile)](20-3.1.2/Dockerfile)*
* `22-3.1.2` *[(22-3.1.2/Dockerfile)](22-3.1.2/Dockerfile)*
* `22-3.1.4` *[(22-3.1.4/Dockerfile)](22-3.1.4/Dockerfile)*
* `22-3.2.2` *[(22-3.2.2/Dockerfile)](22-3.2.2/Dockerfile)*
* `22-3.2.4` *[(22-3.2.4/Dockerfile)](22-3.2.4/Dockerfile)*
* `24-3.2.2` *[(22-3.2.4/Dockerfile)](24-3.2.2/Dockerfile)*
* `24-3.2.4` *[(22-3.2.4/Dockerfile)](24-3.2.4/Dockerfile)*
* `24-3.3.4` *[(22-3.3.4/Dockerfile)](24-3.3.4/Dockerfile)*
* `24-3.3.5` *[(22-3.3.5/Dockerfile)](24-3.3.5/Dockerfile)*
* `24-3.3.6` *[(22-3.3.6/Dockerfile)](24-3.3.6/Dockerfile)*
* `24-3.3.7` *[(22-3.3.7/Dockerfile)](24-3.3.7/Dockerfile)*

_Tag format: `<Heroku Buildpack version>-<Ruby version>`_

_We try to stay up-to-date with the new supported Heroku images. If you see any new one on [this page](https://devcenter.heroku.com/articles/ruby-support#supported-runtimes) feel free to open a PR!_

_There are a couple of version numbers that we have to have in sync with Heroku. Check the [Dockerfile](Dockerfile.template) for those versions and the links where the Heroku version is kept. If you see any new version feel free to open a PR!_


### Motivation
The Heroku base images for ruby got [deprecated](https://github.com/heroku/docker-ruby) in favor of a more [build-your-own Dockerfile strategy](https://devcenter.heroku.com/articles/local-development-with-docker-compose). But I still feel that a base image for Rails serves its purposes. There is no point for each developer to replicate much of the instructions I've used here. The more automation the better amirite?


### Usage
The root folder for your Rails project must have a `Gemfile` and `Gemfile.lock` file. Then build a Dockerfile for your project with this image as base, and with other project-specific instructions `FROM ghrc.io/flecto-io/heroku-rails:20-2.7.4`.

Then you can either run it with standard Docker `docker run --rm -ti your-project` or, more commonly from a Docker Compose based development `$ docker-compose up web`.

_For more details regarding local development with docker read this [Heroku article](https://devcenter.heroku.com/articles/local-development-with-docker-compose)_


### Post-run script
This container comes with a [post-run script](init.sh) that:
- Checks and install any missing gem.
- Precompile your assets if you are in production mode (checks `$RAILS_ENV` value).
- **Run your own run other post-run scripts**. Just add them to `/app/.profile/` folder.

Subsequent runs will use cached changes. This is useful to avoid you from (1) having to rebuild the images each time there is a change on your Gemfile, (2) from having to run a shell just to deploy pending migrations, and (3) to precompile assets if you want to test production mode.


### License

MIT (see LICENSE file)
