DATASET=GoogleNews-vectors-negative300

main: priv/data/$(DATASET).bin.gz

priv/data/$(DATASET).bin.gz:
	mkdir -p priv/data
	curl -o "$@" https://s3.amazonaws.com/dl4j-distribution/$(DATASET).bin.gz
