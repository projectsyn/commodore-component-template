include Makefile.vars.mk

.PHONY: render
render: clean
	poetry run cruft create file://. --no-input --extra-context='$(cruft_extra_content)'

.PHONY: test
test: render
	make -C test-component lint

.PHONY: clean
clean:
	rm -rf ./test-component

.PHONY: sync\:noop
sync\:noop:
	./run-sync.sh --dry-run components.yaml
