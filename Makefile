GODOT_BIN ?= godot

build-web: | docs
	$(GODOT_BIN) --headless --export-debug "Web"

dist: godot-dockable-container.zip

docs:
	mkdir -p $@
	touch $@/.gdignore

gdformat:
	gdformat .

gdformat-check:
	gdformat --diff .

gdlint:
	gdlint .

godot-dockable-container.zip:
	zip $@ -r addons

static-checks: gdlint gdformat-check

.PHONY: build-web dist gdformat gdformat-check gdlint godot-dockable-container.zip static-checks
