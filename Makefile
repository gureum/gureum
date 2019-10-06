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
	@command -v brew >/dev/null || { echo 'Error: Homebrew is not installed. See https://brew.sh'; exit 1; }
	@if ! command -v shellcheck >/dev/null; then \
		echo 'brew install shellcheck'; \
		brew install shellcheck; \
	fi
	@if ! command -v swiftformat >/dev/null; then \
		echo 'brew install swiftformat'; \
		brew install swiftformat; \
	fi

gem-install:
	@if ! command -v pod >/dev/null; then \
		echo 'gem install cocoapods'; \
		gem install cocoapods || { echo 'Error: gem-install failed. Try sudo make gem-install.'; exit 1; }; \
	fi
	@if ! command -v xcpretty >/dev/null; then \
		echo 'gem install xcpretty'; \
		gem install xcpretty || { echo 'Error: gem-install failed. Try sudo make gem-install.'; exit 1; }; \
	fi

.PHONY: all init format brew-install gem-install
