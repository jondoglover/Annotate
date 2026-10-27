PROJECT := Annotate.xcodeproj
SCHEME := Annotate
DERIVED_DATA := .build/Xcode
XCODEBUILD := xcodebuild -quiet -project $(PROJECT) -scheme $(SCHEME) -destination 'platform=macOS' -derivedDataPath $(DERIVED_DATA)

.PHONY: build test run clean

build:
	$(XCODEBUILD) -configuration Debug build

test:
	$(XCODEBUILD) -configuration Debug test

run: build
	open $(DERIVED_DATA)/Build/Products/Debug/Annotate.app

clean:
	$(XCODEBUILD) clean
