.PHONY: analyze build check clean docs prep

build:
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
