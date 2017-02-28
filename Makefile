Name = Oak

all:
	@swift build  -c release

debug:
	@swift build

installd:
	@cp ./.build/debug/OakSim ~/bin/oak

fastdeb:
	@swift build
	@cp ./.build/debug/OakSim ~/bin/oak

install:
	@cp ./.build/release/OakSim ~/bin/oak

clean:
	@rm -rf .build/