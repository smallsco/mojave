#!/bin/bash

mkdir -p ./tmp

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>BuildMachineOSBuild</key>
	<string>13D65</string>
	<key>CFBundleDevelopmentRegion</key>
	<string>English</string>
	<key>CFBundleDocumentTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeIconFile</key>
			<string>$osxFileIcon</string>
			<key>CFBundleTypeName</key>
			<string>LÖVE Project</string>
			<key>CFBundleTypeRole</key>
			<string>Viewer</string>
			<key>LSHandlerRank</key>
			<string>Owner</string>
			<key>LSItemContentTypes</key>
			<array>
				<string>org.love2d.love-game</string>
			</array>
		</dict>
		<dict>
			<key>CFBundleTypeName</key>
			<string>Folder</string>
			<key>CFBundleTypeOSTypes</key>
			<array>
				<string>fold</string>
			</array>
			<key>CFBundleTypeRole</key>
			<string>Viewer</string>
			<key>LSHandlerRank</key>
			<string>None</string>
		</dict>
	</array>
	<key>CFBundleExecutable</key>
	<string>love</string>
	<key>CFBundleIconFile</key>
	<string>$osxBundleIcon</string>
	<key>CFBundleIdentifier</key>
	<string>$identifier</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$friendlyPackageName</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>$version</string>
	<key>CFBundleSignature</key>
	<string>LoVe</string>
	<key>DTCompiler</key>
	<string>com.apple.compilers.llvm.clang.1_0</string>
	<key>DTPlatformBuild</key>
	<string>5B1008</string>
	<key>DTPlatformVersion</key>
	<string>GM</string>
	<key>DTSDKBuild</key>
	<string>13C64</string>
	<key>DTSDKName</key>
	<string>macosx10.9</string>
	<key>DTXcode</key>
	<string>0511</string>
	<key>DTXcodeBuild</key>
	<string>5B1008</string>
	<key>LSApplicationCategoryType</key>
	<string>public.app-category.games</string>
	<key>NSHumanReadableCopyright</key>
	<string>© $copyrightYear $author</string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
</dict>
</plist>" > ./tmp/Info.plist

echo "  Info.plist generated."
