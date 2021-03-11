LövePackaging
=============

[![GitHub release](https://img.shields.io/github/release/TangentFoxy/LovePackaging.svg?maxAge=2592000)](https://github.com/TangentFoxy/LovePackaging/releases/latest)
[![GitHub downloads](https://img.shields.io/github/downloads/TangentFoxy/LovePackaging/latest/total.svg?maxAge=2592000)](https://github.com/TangentFoxy/LovePackaging/releases/latest)
[![GitHub issues](https://img.shields.io/github/issues-raw/TangentFoxy/LovePackaging.svg?maxAge=2592000)](https://github.com/TangentFoxy/LovePackaging/issues)
[![GitHub license](https://img.shields.io/github/license/TangentFoxy/LovePackaging.svg?maxAge=2592000)](https://github.com/TangentFoxy/LovePackaging/blob/master/LICENSE)

Scripts to create LÖVE packages.

Currently working in Linux, untested in OS X (though it should work assuming you
have wget installed), and undeveloped for Windows.

Features
--------

- Builds executables for distribution on Windows and Mac. (Unfortunately, Linux isn't quite that simple, and requires the end-user to have `love` installed.)
- Supports including extra files automatically.
- Can automatically number builds.

Installation
------------

(Note that this guide may differ from the one in the latest release, refer to the ReadMe there for 100% correct info!)

Quick Guide:

1. Download the [latest release](https://github.com/Guard13007/LovePackaging/releases)!
2. Copy the files wherever you want, inside your own repo, outside, wherever!
3. Edit `lp-config.sh` to specify options on how your packages will be built, including where the sources are and where to put the result.
4. Run `./lp-build.sh` for Linux / Mac OS X (OSX users need wget installed!!).
   No Windows version yet, sorry.

A quick note to mention: The build script must be run from its own directory. Everything in the config.sh should be absolute directories.
