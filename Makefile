DATASET=GoogleNews-vectors-negative300

main: priv/data/$(DATASET).txt

priv/data/%.txt: priv/data/%.bin.gz src/convertvec
	mkdir -vp priv/data
	cat "$<" | gunzip | src/convertvec > "$@"

priv/data/$(DATASET).bin.gz:
	mkdir -p data
	curl -o "$@" https://s3.amazonaws.com/dl4j-distribution/$(DATASET).bin.gz

src/convertvec:
	$(MAKE) -C src
