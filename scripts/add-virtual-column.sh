#!/usr/bin/env sh

DB=$1

sqlite-utils query $DB 'ALTER TABLE places 
ADD COLUMN spider TEXT 
GENERATED ALWAYS AS (json_extract(properties, "$.@spider")) VIRTUAL'

sqlite-utils create-index $DB places spider --if-not-exists
