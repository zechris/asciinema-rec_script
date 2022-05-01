export PATH := bin:$(PATH)

all: casts

casts:
	$(foreach file, $(wildcard ./screencasts/*.asc), $(file);)

casts_upload:
	@bash -c "./screencasts/upload.sh"
