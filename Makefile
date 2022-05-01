export PATH := bin:$(PATH)

all: casts

casts:
	$(foreach file, $(wildcard ./screencasts/*.asc), $(file);)
