all:
	@echo 'Available commands:'
	@echo '    format: format code style with swiftformat'

format:
	swiftformat OSXCore/ OSX/ GureumTests/ Preferences/ OSXTestApp/
