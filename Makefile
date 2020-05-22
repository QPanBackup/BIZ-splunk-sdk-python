# text reset
NO_COLOR=\033[0m
# green
OK_COLOR=\033[32;01m
# red
ERROR_COLOR=\033[31;01m
# cyan
WARN_COLOR=\033[36;01m
# yellow
ATTN_COLOR=\033[33;01m

ROOT_DIR := $(shell git rev-parse --show-toplevel)

VERSION := `git describe --tags --dirty 2>/dev/null`
COMMITHASH := `git rev-parse --short HEAD 2>/dev/null`
DATE := `date "+%FT%T%z"`

.PHONY: all
all: build_app test

init:
	@echo "$(ATTN_COLOR)==> init $(NO_COLOR)"

.PHONY: build_app
build_app:
	@echo "$(ATTN_COLOR)==> build_app $(NO_COLOR)"
	@python setup.py build dist

.PHONY: test
test:
	@echo "$(ATTN_COLOR)==> test $(NO_COLOR)"
	@tox -e py27,py37

.PHONY: test_specific
test_specific:
	@echo "$(ATTN_COLOR)==> test_specific $(NO_COLOR)"
	@sh ./scripts/test_specific.sh

.PHONY: test_smoke
test_smoke:
	@echo "$(ATTN_COLOR)==> test_smoke $(NO_COLOR)"
	@tox -e py27,py37 -- -m smoke

.PHONY: test_no_app
test_no_app:
	@echo "$(ATTN_COLOR)==> test_no_app $(NO_COLOR)"
	@tox -e py27,py37 -- -m "not app"

.PHONY: test_smoke_no_app
test_smoke_no_app:
	@echo "$(ATTN_COLOR)==> test_smoke_no_app $(NO_COLOR)"
	@tox -e py27,py37 -- -m "smoke and not app"

.PHONY: splunkrc
splunkrc:
	@echo "$(ATTN_COLOR)==> splunkrc $(NO_COLOR)"
	@echo "To make a .splunkrc:"
	@echo "  [SPLUNK_INSTANCE_JSON] | python scripts/build-splunkrc.py ~/.splunkrc"

.PHONY: splunkrc_default
splunkrc_default:
	@echo "$(ATTN_COLOR)==> splunkrc_default $(NO_COLOR)"
	@python scripts/build-splunkrc.py ~/.splunkrc

.PHONY: up
up:
	@echo "$(ATTN_COLOR)==> up $(NO_COLOR)"
	@docker-compose up -d

.PHONY: wait_up
wait_up:
	@echo "$(ATTN_COLOR)==> wait_up $(NO_COLOR)"
	@for i in `seq 0 180`; do if docker exec -it splunk /sbin/checkstate.sh &> /dev/null; then break; fi; printf "\rWaiting for Splunk for %s seconds..." $$i; sleep 1; done

.PHONY: down
down:
	@echo "$(ATTN_COLOR)==> down $(NO_COLOR)"
	@docker-compose stop
