.PHONY: analyze build check clean prep

build:
	echo TODO: build the package

prereqs:
	BuildSystem/common/update_prereqs.py

check: build
	echo TODO: run tests

analyze:
	echo TODO: run analyze

clean:
	rm -rf *~
