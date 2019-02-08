#!/bin/bash -xe
# Set ruby version and gemset via Jenkins' rvm plugin

clean_up() {
  rm fifo
}

mkdir -p tmp

# Environmental variables needed for the tests to pass
export CI_DB='ci_rdcat'

if [ -z $RAILS_ENV ]; then
    export RAILS_ENV=test
fi

# Bump bundler version after making sure it works
export BUNDLER_VERSION=1.16.0

set +e
gem list -i bundler -v $BUNDLER_VERSION
if [ $? -ne 0 ]; then
  set -e
  gem install bundler -v $BUNDLER_VERSION
fi
set -e

ruby -v
rvm current

bundle _${BUNDLER_VERSION}_ install

bundle _${BUNDLER_VERSION}_ exec rails db:environment:set
bundle _${BUNDLER_VERSION}_ exec rails db:drop
bundle _${BUNDLER_VERSION}_ exec rails db:create
bundle _${BUNDLER_VERSION}_ exec rails db:schema:load

# The exit code is set to 1 on ci even when there are no failures.
# Debugging things on that server is very difficult.
# So we go bash gymnastics until someone takes time to fix this properly.
set +e
mkfifo fifo
RESULTS=`mktemp`
bundle _${BUNDLER_VERSION}_ exec rspec --backtrace --format documentation | { cat fifo & tee fifo | grep -E '[0-9]+ examples, [0-9]+ failure' > $RESULTS; }

EXIT_CODE=$([[ `cat $RESULTS |cut -f2 -d',' |tail -n 1 |grep -o '[0-9]\+'` == 0 ]])$?
rm $RESULTS

trap clean_up EXIT

exit $EXIT_CODE
