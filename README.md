# Chromecastise
This project aims to provide a simple wrapper around the ffmpeg and mediainfo
tools to allow simple transcoding of video files for use with both the
original chromecast device and iOS devices. I currently use minidlnad to share
my video files with my chromecast device and iOS tablet. I needed a way to make
sure that the media supports both of these devices. Unfortunately the ffmpeg
transcode command was quite long and I found it hard to remember so I produced
this command line tool to do the conversion for me.
