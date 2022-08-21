export PATH := bin:$(PATH)

SCREENCASTS_DIR := screencasts

outputs := $(foreach file, $(wildcard $(SCREENCASTS_DIR)/*.asc), $(patsubst %.asc,%.cast,$(file)))

casts: $(outputs)

$(SCREENCASTS_DIR)/%.cast: $(SCREENCASTS_DIR)/%.asc
	asciinema-rec_script $(patsubst %.cast,%.asc,$@)

casts_upload:
	upload.sh

list:
	ls $(SCREENCASTS_DIR)

clean:
	$(RM) $(SCREENCASTS_DIR)/*.cast
