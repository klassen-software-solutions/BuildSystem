.PHONY: prep build check clean analyze install

# Only include the license file dependancy if there are prerequisites to examine.
PREREQS_LICENSE_FILE := Dependancies/prereqs-licenses.json
ifeq ($(wildcard Dependancies/prereqs.json),)
    PREREQS_LICENSE_FILE :=
endif

# Force the version to be updated.
VERSION := $(shell BuildSystem/common/revision.sh --format=python)
VERSION_FILE := $(PREFIX)/$(PACKAGE)/_version.py


build: $(PREREQS_LICENSE_FILE) $(VERSION_FILE) REVISION
	python3 setup.py sdist bdist_wheel

$(PREREQS_LICENSE_FILE): Dependancies/prereqs.json
	BuildSystem/common/license_scanner.py

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
