.PHONY: bindgen

release:
	odin build . --subsystem:windows

debug:
	odin build . --debug

bindgen:
	odin run ./bindgen
