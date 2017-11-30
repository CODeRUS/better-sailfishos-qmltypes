import QtQuick 2.0
import Sailfish.Silica 1.0

Row {
    property date eventDate
    property bool showTime
    property bool timeContinued

    spacing: Theme.paddingMedium

    Column {
        Text {
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.highlightColor
            opacity: 0.7
            text: Format.formatDate(eventDate, Format.WeekdayNameStandalone)
        }
        Text {
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.highlightColor
            opacity: 0.7
            text: {
                var d = eventDate
                var result
                if (d.getFullYear() != (new Date).getFullYear()) {
                    result = Format.formatDate(d, Format.DateLong)
                } else {
                    //% "d MMMM"
                    result = Qt.formatDate(d, qsTrId("sailfish_calendar-date_pattern_date_month"))
                }

                if (timeContinued && !showTime) {
                    result += " -"
                }

                return result
            }
        }
    }

    Text {
        anchors.bottom: parent.bottom
        visible: showTime
        font.pixelSize: Theme.fontSizeMedium
        color: Theme.highlightColor
        text: Format.formatDate(eventDate, Formatter.TimeValue) + (timeContinued ? " -" : "")
    }
}
