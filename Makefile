.PHONY: analyze build

build:

analyze:
	pylint \
		common/*.py \
		python/*.py
	shellcheck \
		c++/*.sh \
		common/*.sh \
		python/*.sh \
		swift/*.sh
