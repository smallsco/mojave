#!/bin/bash

# keep unset variables from breaking everything
set -o nounset
# exit on error instead of continuing
set -o errexit

# get config
#if [ ! -z "$1" ]; then
#	# has a command-line option, which should be the config file to load from
#	source "$1"
#else
	source ./lp-config.sh
#fi

# make $outputDir if it doesn't exist
if [ ! -d "$outputDir" ]; then mkdir -p "$outputDir"; fi

# append -buildN build numbers
#  (build.number file stored in $outputDir)
if [ $autoNumberBuilds = true ]; then
	# get the number if file exists, else use 1
	if [ -r "$outputDir/build.number" ]; then
		source "$outputDir/build.number"
		((build++))
	else
		build=1
	fi
	# store the current build number
	echo "build=$build" > "$outputDir/build.number"
	# set version to use new build number
	version=$version-$build
fi

# check that zip and unzip are accessible
#  not sure if this is the best way to do this or not
if ! which zip > /dev/null 2>&1; then
	echo "zip not installed"
	exit 2;
fi
if ! which unzip > /dev/null 2>&1; then
	echo "unzip not installed"
	exit 3;
fi

# remove old versions of package?
if [ $removeOld = true ]; then
	rm -f "$outputDir/$packageName*"
fi

# move to source dir and store original for later use
# (this is to make a zip command work)
originalDir=$(pwd)
cd "$sourceDir"

# build .love file
echo "Building $packageName (version $version)... (.love file)"
zip -r -X -y -q "$outputDir/$packageName-$version.love" ./*
echo "  Done."

# check if executables exist, if not, download them
#   (assumes if the exe exists, everything else does too)
if [ ! -r "$win64Dir/love-$loveVersion-win64/love.exe" ]; then
	mkdir -p "$win64Dir"
	echo "Downloading win64src..."
	$download "$win64Dir/love64.zip" https://github.com/love2d/love/releases/download/$loveVersion/love-$loveVersion-win64.zip
	echo "  Done."
	echo "Extracting win64src..."
	unzip -q "$win64Dir/love64.zip" -d "$win64Dir"
	echo "  Done."
	echo "Deleting ZIP file..."
	rm -f "$win64Dir/love64.zip"
	echo "  Done."
fi

if [ ! -d "$osx10Dir/love.app" ]; then
	mkdir -p "$osx10Dir"
	echo "Downloading osx10src..."
	$download "$osx10Dir/loveOSX.zip" https://github.com/love2d/love/releases/download/$loveVersion/love-$loveVersion-macos.zip
	echo "  Done."
	echo "Extracting osx10src..."
	unzip -q "$osx10Dir/loveOSX.zip" -d "$osx10Dir"
	# delete Mac crap (for some reason can't not unzip it *shrugs*)
	rm -rf "$osx10Dir/__MACOSX"
	# the Info.plist is generated each time a package is built, we don't need a copy here
	rm -f "$osx10Dir/love.app/Contents/Info.plist"
	echo "  Done."
	echo "Deleting ZIP file..."
	rm -f "$osx10Dir/loveOSX.zip"
	echo "  Done."
fi

# build executables and zip files for them

echo "Building $packageName (version $version)... (win64 zip)"
# EXE with ZIP at end
cat "$win64exe" "$outputDir/$packageName-$version.love" > "$win64Dir/$packageName.exe"
cd "$win64Dir"
# ZIP up the EXE
zip -r -X -y -q "$outputDir/$packageName-${version}_win64.zip" "./$packageName.exe"
cd ./love-$loveVersion-win64
# ZIP up the required DLLs
zip -r -X -y -q "$outputDir/$packageName-${version}_win64.zip" ./*.dll
cp ./license.txt ./LOVE-license.txt
# ZIP up the LOVE license
zip -r -X -y -q "$outputDir/$packageName-${version}_win64.zip" ./LOVE-license.txt
# ZIP up extra included files
if [ "$(ls -A $includes)" ]; then
	cd "$includes"
	zip -r -X -y -q "$outputDir/$packageName-${version}_win64.zip" ./*
fi
echo "  Done."

echo "Building $packageName (version $version)... (OS X zip)"
cd "$osx10Dir"
# Make a fresh copy of the .app directory
rm -rf "./$packageName.app"
cp -R ./love.app "./$packageName.app"
# Copy in our .love file
cp "$outputDir/$packageName-$version.love" "$osx10Dir/$packageName.app/Contents/Resources/$packageName.love"
# Copy in our icons
cp "$osxIconsDirectory/$osxFileIcon" "$osx10Dir/$packageName.app/Contents/Resources/$osxFileIcon"
cp "$osxIconsDirectory/$osxBundleIcon" "$osx10Dir/$packageName.app/Contents/Resources/$osxBundleIcon"
# Create an Info.plist and copy it in
cd "$originalDir"
source "$originalDir/lp-scripts/Info.plist-maker.sh"
cd "$osx10Dir"
cp "$originalDir/tmp/Info.plist" "$osx10Dir/$packageName.app/Contents/Info.plist"
rm -rf "$originalDir/tmp"
# ZIP up the .app directory
zip -r -X -y -q "$outputDir/$packageName-${version}_osx.zip" "./$packageName.app"
# ZIP up the extra included files
if [ "$(ls -A $includes)" ]; then
	cd "$includes"
	zip -r -X -y -q "$outputDir/$packageName-${version}_osx.zip" ./*
fi
echo "  Done."

echo "Building $packageName (version $version)... (Linux zip)"
cd "$outputDir"
# ZIP up the .love file
zip -r -X -y -q "./$packageName-${version}_linux.zip" "./$packageName-$version.love"
cp "$win64Dir/love-$loveVersion-win64/LOVE-license.txt" ./LOVE-license.txt
# ZIP up the LOVE license
zip -r -X -y -q "./$packageName-${version}_linux.zip" ./LOVE-license.txt
# ZIP up the extra included files
if [ "$(ls -A $includes)" ]; then
	cd "$includes"
	zip -r -X -y -q "$outputDir/$packageName-${version}_linux.zip" ./*
fi
echo "  Done."

if [ $latestBuilds = true ]; then
	mkdir -p "$latestBuildsDir"
	rm -f "$latestBuildsDir/*"
	cp "$outputDir/$packageName-${version}_win64.zip" "$latestBuildsDir"
	cp "$outputDir/$packageName-${version}_osx.zip" "$latestBuildsDir"
	cp "$outputDir/$packageName-${version}_linux.zip" "$latestBuildsDir"
fi

echo "Builds complete. Unless there are errors above. Double check your files."
echo
if which fortune > /dev/null 2>&1; then fortune; fi
