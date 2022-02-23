
URL=https://data.alltheplaces.xyz/runs/2022-02-19-13-31-46/output.tar.gz

output.tar.gz:
	wget -O $@ $(URL)

alltheplaces.db:
	pipenv run sqlite-utils create-database --enable-wal --init-spatialite $@
	sqlite-utils create-table $@ places id text properties text --pk id
	sqlite-utils add-geometry-column $@ places geometry

update: output.tar.gz
	tar -zxvf $^
	find output -type f -empty -delete

build: alltheplaces.db
	find output/*.geojson | parallel -j 2 pipenv run geojson-to-sqlite $^ places {} --spatialite --properties

run: alltheplaces.db
	pipenv run datasette serve $^ \
		--load-extension spatialite \
		-m metadata.yml \
		--setting sql_time_limit_ms 10000

clean:
	rm -rf output/ output.*
