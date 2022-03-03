
URL=https://data.alltheplaces.xyz/runs/2022-02-26-13-31-55/output.tar.gz

DB=alltheplaces.db

output.tar.gz:
	wget -O $@ $(URL)

processed/states_carto_2018.geojson:
	pipenv run censusmapdownloader states-carto

processed/counties_2020.geojson:
	pipenv run censusmapdownloader counties

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
	find output/*.geojson | xargs -I {} pipenv run geojson-to-sqlite $(DB) places {} --spatialite --properties
	pipenv run create-spatial-index $(DB) places geometry

states: processed/states_carto_2018.geojson
	pipenv run geojson-to-sqlite $(DB) states $^ --pk geoid --spatialite
	pipenv run sqlite-utils create-spatial-index $(DB) states geometry

counties: processed/counties_2020.geojson
	pipenv run geojson-to-sqlite $(DB) counties $^ --pk geoid --spatialite
	pipenv run sqlite-utils create-spatial-index $(DB) counties geometry

run: alltheplaces.db
	pipenv run datasette serve *.db \
		--load-extension spatialite \
		-m metadata.yml \
		--setting sql_time_limit_ms 20000

publish:
	pipenv run datasette publish fly *.db \
		--app alltheplaces-datasette \
		--spatialite \
		-m metadata.yml \
		--install datasette-geojson-map \
		--install sqlite-colorbrewer \
		--extra-options="--setting sql_time_limit_ms 5000"

open:
	flyctl open --app alltheplaces-datasette

clean:
	rm -rf output/ output.*
