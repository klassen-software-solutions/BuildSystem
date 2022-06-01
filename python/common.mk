.PHONY: prep build check clean analyze install

# Only include the license file dependancy if there are prerequisites to examine.
LICENSE_DEPENDENCIES :=
ifneq ($(wildcard Dependencies/manual-licenses.json),)
	LICENSE_DEPENDENCIES := $(LICENSE_DEPENDENCIES) Dependencies/manual-licenses.json
endif

ifneq ($(wildcard Dependencies/prereqs.json),)
    LICENSE_DEPENDENCIES := $(LICENSE_DEPENDENCIES) Dependencies/prereqs.json
endif

PREREQS_LICENSE_FILE := Dependencies/prereqs-licenses.json
ifeq ($(LICENSE_DEPENDENCIES),)
    PREREQS_LICENSE_FILE :=
endif

# Force the version to be updated.
VERSION := $(shell BuildSystem/common/revision.sh --format=python)
VERSION_FILE := $(PREFIX)/$(PACKAGE)/_version.py


build: $(PREREQS_LICENSE_FILE) $(VERSION_FILE) REVISION
	python3 setup.py sdist bdist_wheel

$(PREREQS_LICENSE_FILE): $(LICENSE_DEPENDENCIES)
	-license-scanner

$(VERSION_FILE): REVISION
	BuildSystem/python/update_version.sh $(PREFIX) $(PACKAGE)

prereqs:
	BuildSystem/common/update_prereqs.py

check: build
	python3 -m unittest discover --start-directory Tests

analyze:
	BuildSystem/python/python_analyzer.py $(PREFIX)

install: build
	python3 -m pip install --user .

clean:
	rm -rf build dist *.egg-info REVISION
