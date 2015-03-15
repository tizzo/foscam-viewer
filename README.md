# Foscam Viewer

A simple webapp for viewing a foscam camera powered by node.js. The default foscam webapp
is pretty clunky and even the mobile version works poorly on mobile. The goal of this application
is to provide a simple mobile friendly application to view a foscam camera stream from a browser.

## Compatibility

### Known Issues

Streaming mjpgs do not seem to work on mobile Chrome for iOS at present. Mobile Safari has been tested and at the time of writing currently works, but according to the Internet apple has broken or disabled it in the past. 

### Cameras

This app has only been tested with the [FI8910W](http://foscam.us/products/foscam-fi8910w-wireless-ip-camera.html) model but will likely work with most foscam models that expose video via [MJPEG](http://en.wikipedia.org/wiki/Motion_JPEG).  This would likely not include newer HD models that stream H264, though pull requests to add that are most welcome.

## Installing and Running

  1. Install [node.js and npm](https://nodejs.org/).
  2. Install foscam viewer `sudo npm install -g fosscam-viewer coffee-script`
  3. Create a config.yaml ([copy the default](https://github.com/tizzo/foscam-viewer/blob/master/default-config.yaml) and edit to taste)
  4. Run `foscam-viewer /path/to/config.yaml`
