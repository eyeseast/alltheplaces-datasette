
URL=https://data.alltheplaces.xyz/runs/2022-01-15-13-32-25/output.tar.gz

output.tar.gz:
	wget -O $@ $(URL)

alltheplaces.db:
	pipenv run sqlite-utils create-database --enable-wal $@

update: output.tar.gz
	tar -zxvf $^

build: alltheplaces.db
	find output/*.geojson | xargs -I {} pipenv run geojson-to-sqlite $^ places {} --spatialite --alter

run: alltheplaces.db
	pipenv run datasette serve $^ --load-extension spatialite

clean:
	rm -rf output/ output.*
