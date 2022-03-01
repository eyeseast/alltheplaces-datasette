
URL=https://data.alltheplaces.xyz/runs/2022-02-26-13-31-55/output.tar.gz

DB=alltheplaces.db

output.tar.gz:
	wget -O $@ $(URL)

processed/states_carto_2018.geojson:
	pipenv run censusmapdownloader states-carto

alltheplaces.db:
	pipenv run sqlite-utils create-database --enable-wal --init-spatialite $@
	pipenv run sqlite-utils create-table $@ places \
		id text \
		properties text \
		--pk id
	pipenv run sqlite-utils add-geometry-column $@ places geometry

update: output.tar.gz
	tar -zxvf $^
	find output -type f -empty -delete

build: $(DB)
	pipenv run find output/*.geojson | parallel -j 3 geojson-to-sqlite $^ places {} --spatialite --properties

states: processed/states_carto_2018.geojson
	pipenv run geojson-to-sqlite $(DB) states $^ --pk geoid --spatialite

run: alltheplaces.db
	pipenv run datasette serve *.db \
		--load-extension spatialite \
		-m metadata.yml \
		--setting sql_time_limit_ms 20000

clean:
	rm -rf output/ output.*
