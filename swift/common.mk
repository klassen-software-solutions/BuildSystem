.PHONY: analyze build check clean docs forcelicense prep

LICENSE_DEPENDENCIES :=
ifneq ($(wildcard Dependencies/manual-licenses.json),)
	LICENSE_DEPENDENCIES := $(LICENSE_DEPENDENCIES) Dependencies/manual-licenses.json
endif
ifneq ($(wildcard Package.swift),)
	LICENSE_DEPENDENCIES := $(LICENSE_DEPENDENCIES) Package.swift
endif

build: forcelicense
	swift build

prereqs:
	BuildSystem/common/update_prereqs.py

check: build
	swift test

analyze:
	echo TODO: run analyze

docs:
	env AUTHOR="$(AUTHOR)" AUTHOR_URL="$(AUTHOR_URL)" BuildSystem/swift/generate_docs.py

clean:
	rm -rf *~

cleanall: clean
	rm -rf docs

forcelicense: Dependencies/prereqs-licenses.json

Dependencies/prereqs-licenses.json: $(LICENSE_DEPENDENCIES)
	license-scanner
