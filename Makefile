all:
	@echo 'Available commands:'
	@echo '    init         -- setup a development environment'
	@echo '    format       -- format code style with swiftformat'
	@echo '    brew-install -- install required Homebrew formulae'
	@echo '    gem-install  -- install required gems'

init: brew-install gem-install
	git submodule update --init --recursive
	pod install --repo-update

format:
	swiftformat OSXCore/ OSX/ GureumTests/ Preferences/ OSXTestApp/

brew-install:
	@command -v brew >/dev/null || { echo 'Homebrew is not installed. See https://brew.sh'; exit 1; }
	brew install shellcheck swiftformat

gem-install:
	@echo 'gem install cocoapods xcpretty'
	@gem install cocoapods xcpretty || { echo 'gem-install failed. Try sudo make gem-install.'; exit 1; }

.PHONY: all init format brew-install gem-install
