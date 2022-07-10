# NOTE: To see a list of typical targets, execute `make help` <>

SHELL = /usr/bin/env bash

PROJ = transcraft
SUB := $(shell az account show -o tsv --query id)

LOGS = debug info warn error fatal
export LOG ?= warn

ENVS = dev prod
ENV ?= dev

GROUP = $(PROJ)-$(ENV)
LOCATION = centralus

BASTION = tulip-$(ENV)
MACHINE = lilac-$(ENV)
SERVICE = peony-$(ENV)

OUTDIR = out
ENVDIR = $(OUTDIR)/$(ENV)
KEYDIR = $(ENVDIR)/key
MIMEDIR = $(ENVDIR)/mime

PRIVKEY = $(KEYDIR)/id_rsa
PUBKEY = $(PRIVKEY).pub
KEYS = $(PRIVKEY) $(PUBKEY)

MIME= $(MIMEDIR)/cloud-init.mime

# general:
ALL = $(MIME) $(KEYS)
VALS = validate-log-level validate-environment

# cleaning targets:
.PHONY: clean reset
clean:
	rm -fv $(MIME)

reset: clean
	rm -fv $(KEYS)

# build targets:
.PHONY: all dirs keys mime

all: dirs keys mime

dirs: $(KEYDIR) $(MIMEDIR)
$(KEYDIR):
	mkdir -p $(KEYDIR)

$(MIMEDIR):
	mkdir -p $(MIMEDIR)

keys: $(KEYS)
$(KEYS) &: $(KEYDIR)
	make/build/keyfiles.bash -e $(ENV) -k $(PRIVKEY)

mime: $(MIME)
$(MIME): $(MIMEDIR) cloud-init/*/*
	make/build/mime.bash -u $(MIME)

# deployment targets:
.PHONY: resource-group service-principal arm-deployment

resource-group: $(VALIDATIONS)
	make/deploy/resource-group.bash -g $(GROUP_NAME) -l $(GROUP_LOC)

service-principal: $(VALIDATIONS)
	make/deploy/service-principal.bash \
	  --subscription-id $(SUB_ID)
		--resource-group  $(GROUP_NAME) -l $(GROUP_LOC)

arm-deployment: validate-log-level $(ALL_FILES)
	make/deploy/deploy.bash -b $(BASTION) -l $(GROUP_LOC) -g $(GROUP_NAME) -m $(MACHINE)

# utility targets:
.PHONY: prequisites connection

prequisites: validate-log-level
	make/util/prequisites.bash

connection: validate-log-level
	make/util/connection.bash -b $(BASTION) -l $(GROUP_LOC) -g $(GROUP_NAME) -m $(MACHINE)

# miscellanous targets:
.PHONY: help validate-log-level validate-environment

help:
	@echo 'Clean targets:'
	@echo ' reset                 - Remove all generated files.'
	@echo ' clean                 - Remove most generated files, but keep keyfiles.'
	@echo ''
	@echo 'Build targets:'
	@echo '  all                  - Build all targets.'
	@echo '  dirs                 - Build output directories.'
	@echo '  keys                 - Build ssh keyfiles.'
	@echo '  mime                 - Build a cloud-init mimefile.'
	@echo ''
	@echo 'Deploy targets:'
	@echo '  arm-deployment       - Deploy a $(PROJ) environment.'
	@echo '  resource-group       - Create an environment resource group.'
	@echo '  service-principal    - Create an environment service principal.'
	@echo
	@echo 'Utility targets:'
	@echo '  connection           - Create a bastion ssh tunnel.'
	@echo '  prequisites          - Install project prerequisites.'
	@echo ''
	@echo 'Miscellaneous targets:'
	@echo '  help                 - Display this usage text.'
	@echo '  validate-log-level   - Validate the log level.'
	@echo '  validate-environment - Validate the environment.'
	@echo ''

validate-log-level:
ifeq ($(filter $(LOG),$(LOGS)),)
	$(error Log level $(LOG) is invalid.)
endif

validate-environment:
ifeq ($(filter $(ENV),$(ENVS)),)
	$(error Environment $(ENV) is invalid.)
endif