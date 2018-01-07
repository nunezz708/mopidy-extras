TAG_PARTS ?= $(subst -, ,$@)
BUILD_ARGS ?= --build-arg MOPIDY_XTRAS_PARENT_TAG=$(firstword $(TAG_PARTS))

include Makefile.docker

