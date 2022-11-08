#!/usr/bin/env sh

# this is the default command to start a docker container
datasette serve . -h 0.0.0.0 \
    -m metadata.yml \
    --cors \
    --setting sql_time_limit_ms 20000 \
    --setting suggest_facets off \
    --setting facet_time_limit_ms 20000 \
    --inspect-file inspect.json \
    --load-extension spatialite
