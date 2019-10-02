all:
	@echo 'Available commands:'
	@echo '    init   -- setup a development environment'
	@echo '    format -- format code style with swiftformat'

init:
	git submodule update --init --recursive
	pod install --repo-update

format:
	swiftformat OSXCore/ OSX/ GureumTests/ Preferences/ OSXTestApp/

.PHONY: all init format
