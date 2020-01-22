.PHONY: analyze build

build:

analyze:
	pylint \
		BuildSystem/common/*.py \
		BuildSystem/python/*.py
	shellcheck \
		BuildSystem/c++/*.sh \
		BuildSystem/common/*.sh
