all:
	@echo 'Available commands:'
	@echo '    init         -- setup a development environment'
	@echo '    format       -- format code style with swiftformat'
	@echo '    xcode-select -- set the active developer directory to Xcode'
	@echo '    brew-install -- install required Homebrew formulae'
	@echo '    gem-install  -- install required gems'

init: xcode-select brew-install gem-install
	git submodule update --init --recursive

format:
	swiftformat OSXCore/ OSX/ GureumTests/ Preferences/ OSXTestApp/

xcode-select:
	@if [ "$(shell xcode-select -p)" = '/Library/Developer/CommandLineTools' ]; then \
		echo 'sudo xcode-select -s /Applications/Xcode.app/Contents/Developer'; \
		sudo xcode-select -s /Applications/Xcode.app/Contents/Developer; \
	fi

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
	@if ! command -v xcpretty >/dev/null; then \
		echo 'gem install xcpretty'; \
		gem install xcpretty || { echo 'Error: gem-install failed. Try sudo make gem-install.'; exit 1; }; \
	fi

.PHONY: all init format xcode-select brew-install gem-install
