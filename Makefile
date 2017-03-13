Name := Oak

UNAME := $(shell uname -s)
ifeq ($(UNAME), Darwin)
	InstallDir := /usr/local/bin
else
	InstallDir := ~/bin/
endif

all:
	@swift build  -c release
	@cp ./.build/release/OakSim ./.build/oak

debug:
	@swift build
	@cp ./.build/debug/OakSim ./.build/oak

install:
	@mkdir -p $(InstallDir)
	@cp ./.build/oak $(InstallDir)

clean:
	@rm -rf .build/