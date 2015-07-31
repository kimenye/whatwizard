#!/bin/bash

#[ -f "tmp/pids/server.pid" ] && kill -9 `cat "tmp/pids/server.pid"`
rails server -p 8080 -e production -d
