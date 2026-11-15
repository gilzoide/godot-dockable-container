GODOT_BIN ?= godot

docs:
	mkdir -p $@
	touch $@/.gdignore

build-web: | docs
	$(GODOT_BIN) --headless --export-debug "Web"

gdformat:
	gdformat .

gdformat-check:
	gdformat --diff .

gdlint:
	gdlint .

static-checks: gdlint gdformat-check

.PHONY: gdformat gdformat-check gdlint static-checks
