#!/bin/bash
# SL: format and dump a gitid into the resources dir.  call this before the build

GIT_COMMIT=$(git rev-parse --short HEAD)
GIT_DIRTY=$(git diff --quiet || echo '-dirty')

echo ${GIT_COMMIT}${GIT_DIRTY} > resources/gitid.txt
