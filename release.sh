#!/bin/bash

cb=kagent
version=grep ^version metadata.rb | perl -pi -e 's/"//g' |  perl -pi -e "s/version\s*//g"

echo "Releasing version: $version of $cb  to Chef supermarket"

berks vendor /tmp/cookbooks
cp metadata.rb /tmp/cookbooks/$cb
knife cookbook site $cb Applications
