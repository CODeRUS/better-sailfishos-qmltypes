import QtMultimedia 5.0

// semi-deprecated, just needed if front camera output needs to be mirrored,
// which doesn't yet happen automatically. dynamically added property is read by
// nemo-qtmultimedia-plugins / videotexturebackend
VideoOutput {
    property bool mirror: false
}
