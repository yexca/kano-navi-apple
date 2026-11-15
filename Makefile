.DEFAULT_GOAL := help

PYTHON ?= python3
SWIFT ?= swift
XCODEBUILD ?= xcodebuild
IOS_DESTINATION ?= platform=iOS Simulator,name=iPhone 17e
MAC_DESTINATION ?= platform=macOS,arch=arm64

.PHONY: help format format-check docs-check check-docs sensitive-check check-sensitive privacy-check test-checks
.PHONY: test-package test-ios test-mac ci-fast check

help:
	@echo "Targets:"
	@echo "  ci-fast          Run format-check, docs-check, test-checks, and sensitive-check"
	@echo "  format           Format Swift sources with swift format"
	@echo "  format-check     Lint Swift formatting without modifying files"
	@echo "  docs-check       Verify local Markdown links"
	@echo "  sensitive-check  Scan repository files for secrets, private paths, and unapproved hosts"
	@echo "  test-checks      Run unit tests for Tools check scripts"
	@echo "  test-package     Run KanoNaviKit Swift package tests"
	@echo "  test-ios         Run KanoNavi scheme tests on iOS Simulator"
	@echo "  test-mac         Run KanoNaviMac scheme tests on macOS"
	@echo "  check            Run ci-fast and package/app tests"

format:
	$(SWIFT) format format --in-place --recursive KanoNavi KanoNaviTests KanoNaviUITests KanoNaviWidgets KanoNaviWidgetsTests Packages/KanoNaviKit/Sources Packages/KanoNaviKit/Tests

format-check:
	$(SWIFT) format lint --recursive KanoNavi KanoNaviTests KanoNaviUITests KanoNaviWidgets KanoNaviWidgetsTests Packages/KanoNaviKit/Sources Packages/KanoNaviKit/Tests

docs-check:
	$(PYTHON) Tools/check-doc-links.py

check-docs: docs-check

sensitive-check:
	$(PYTHON) Tools/check-sensitive.py

check-sensitive privacy-check: sensitive-check

test-checks:
	$(PYTHON) -m unittest Tools/test_checks.py

test-package:
	$(SWIFT) test --package-path Packages/KanoNaviKit

test-ios:
	$(XCODEBUILD) test -project KanoNavi.xcodeproj -scheme KanoNavi -destination '$(IOS_DESTINATION)'

test-mac:
	$(XCODEBUILD) test -project KanoNavi.xcodeproj -scheme KanoNaviMac -destination '$(MAC_DESTINATION)'

ci-fast: format-check docs-check test-checks sensitive-check

check: ci-fast test-package test-ios test-mac
