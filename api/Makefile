export TARGET_FILE = server.cr
export SOURCE_FILES = $(shell find *.cr)

.PHONY: run
run: ./server
	./server
	rm server

./server: $(SOURCE_FILES)
	crystal build --no-debug --progress $(TARGET_FILE)