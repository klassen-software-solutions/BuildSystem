.PHONY: analyze build check clean prep

build:
	swift build

prereqs:
	BuildSystem/common/update_prereqs.py

check: build
	swift test

analyze:
	echo TODO: run analyze

clean:
	rm -rf *~
