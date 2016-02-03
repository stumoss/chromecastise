# Chromecastise
[![Build Status](https://travis-ci.org/stumoss/chromecastise.svg?branch=master)](https://travis-ci.org/stumoss/chromecastise)

This project aims to provide a simple wrapper around the ffmpeg and mediainfo
tools to allow simple transcoding of video files for use with both the
original chromecast device and iOS devices. I currently use minidlnad to share
my video files with my chromecast device and iOS tablet. I needed a way to make
sure that the media supports both of these devices. Unfortunately the ffmpeg
transcode command was quite long and I found it hard to remember so I produced
this command line tool to do the conversion for me.

## Requirements
This project requires both ffmpeg and mediainfo binaries to exist in the path
of your Operating System to work. I have only tested this on Mac OS X but it
should work just as easily on any Linux machine. If you haven't already got
ffmpeg and mediainfo on your system you can install them on Mac OS X using
[Homebrew](http://brew.sh/):

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
$ brew install ffmpeg  --with-fdk-aac --with-ffplay --with-freetype --with-frei0r --with-libass --with-libvorbis --with-libvpx --with-opencore-amr --with-openjpeg --with-opus --with-rtmpdump --with-schroedinger --with-speex --with-theora --with-tools
$ brew install mediainfo
```

## Usage Examples
Converting a single file:

```
$ chromecastise --mp4 YourFileNameHere.avi
```

Converting a number of files within a directory:

```
$ for file in *.avi; do chromecastise --mp4 "$file"; done
```

Once the conversion is done you will probably want to rename the converted files (as by default
you will have a new file with the same original filename but a new suffix of "_new.mp4"):

```
$ for file in *_new.mp4; do mv "$file" "${file%_new.mp4}.mp4"; done
```

This will rename all files from "TheOriginalFileName_new.mp4" to "TheOriginalFileName.mp4".
