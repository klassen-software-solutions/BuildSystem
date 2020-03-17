.PHONY: analyze build check clean docs forcelicense prep

SWIFT_BUILD_COMMAND :=
SWIFT_TEST_COMMAND :=
ifneq ($(wildcard Package.swift),)
	SWIFT_BUILD_COMMAND := swift build
	SWIFT_TEST_COMMAND := swift test
endif


LICENSE_DEPENDENCIES :=
ifneq ($(wildcard Dependencies/manual-licenses.json),)
	LICENSE_DEPENDENCIES := $(LICENSE_DEPENDENCIES) Dependencies/manual-licenses.json
endif

ifneq ($(wildcard Dependencies/prereqs.json),)
    LICENSE_DEPENDENCIES := $(LICENSE_DEPENDENCIES) Dependencies/prereqs.json
endif

ifneq ($(wildcard Package.swift),)
	LICENSE_DEPENDENCIES := $(LICENSE_DEPENDENCIES) Package.swift
endif

_PACKAGE_RESOLVED_FILES := $(shell find . -name 'Package.resolved' -not -path '*/\.*')
LICENSE_DEPENDENCIES := $(LICENSE_DEPENDENCIES) $(_PACKAGE_RESOLVED_FILES)

PREREQS_LICENSE_FILE := Dependencies/prereqs-licenses.json
ifeq ($(LICENSE_DEPENDENCIES),)
    PREREQS_LICENSE_FILE :=
endif


build: forcelicense
	$(SWIFT_BUILD_COMMAND)

prereqs:
	BuildSystem/common/update_prereqs.py

check: build
	$(SWIFT_TEST_COMMAND)

analyze:
	echo TODO: run analyze

docs:
	env AUTHOR="$(AUTHOR)" AUTHOR_URL="$(AUTHOR_URL)" BuildSystem/swift/generate_docs.py

clean:
	rm -rf *~

cleanall: clean
	rm -rf docs

forcelicense: $(PREREQS_LICENSE_FILE)

Dependencies/prereqs-licenses.json: $(LICENSE_DEPENDENCIES)
	license-scanner
