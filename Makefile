Name = Oak

all:
	@swift build  -c release
	@cp ./.build/release/OakSim ./.build/oak

debug:
	@swift build
	@cp ./.build/debug/OakSim ./.build/oak

install:
	@cp ./.build/oak ~/bin/oak

clean:
	@rm -rf .build/