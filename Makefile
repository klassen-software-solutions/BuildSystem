.PHONY: analyze build

build:

analyze:
	pylint \
		common/*.py \
		python/*.py \
		swift/*.py
	shellcheck \
		c++/*.sh \
		common/*.sh \
		python/*.sh \
		swift/*.sh
