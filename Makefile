.PHONY: bindgen

release:
	odin build .

debug:
	odin build . --debug

bindgen:
	odin run ./bindgen
