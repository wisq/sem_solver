DATASET=GoogleNews-vectors-negative300

main: priv/data/$(DATASET).txt

priv/data/%.txt: priv/data/%.bin.gz src/convertvec
	cat "$<" | gunzip | src/convertvec | egrep '^[a-z]+ ' > "$@"

priv/data/$(DATASET).bin.gz:
	mkdir -p priv/data
	curl -o "$@" https://s3.amazonaws.com/dl4j-distribution/$(DATASET).bin.gz

src/convertvec:
	$(MAKE) -C src
