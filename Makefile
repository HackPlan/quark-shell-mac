release:
	xctool \
		-workspace quark-shell.xcworkspace \
		-scheme quark-shell \
		-configuration Release \
		build archive -archivePath archive
	open archive.xcarchive/Products/Applications

.PHONY: release
