/* -*- js -*- */

.pragma library

function formatDuration(duration) {
    var secs = parseInt(duration);
    var minutes = Math.floor(secs / 60);
    var seconds = secs - (minutes * 60);

    var date = new Date();
    date.setSeconds(seconds);
    date.setMinutes(minutes);
    return Qt.formatTime(date, "mm:ss");
}
