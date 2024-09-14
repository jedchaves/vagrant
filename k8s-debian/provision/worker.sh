#!/bin/bash

# The workers privision are splitted in two steps
# so we can release the terminal much earlier
# and also avoid the log polution on screen

# This sed avoids the problem of git adding \r on Windows
sed 's,\r$,,' /vagrant/provision/worker-steps.sh | bash -s $1 > /tmp/provision.log 2>&1 &
