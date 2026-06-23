# Run tests on macOS (Differentiator integration tests only — UIKit excluded)
test:
	GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.bareRepository GIT_CONFIG_VALUE_0=all \
	swift test

# Run full test suite on an iOS Simulator (includes UIKit binding tests)
test-ios:
	xcodebuild test \
		-scheme CxDataSources \
		-destination 'platform=iOS Simulator,name=iPhone 16' \
		GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.bareRepository GIT_CONFIG_VALUE_0=all

build:
	GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.bareRepository GIT_CONFIG_VALUE_0=all \
	swift build

.PHONY: test test-ios build
