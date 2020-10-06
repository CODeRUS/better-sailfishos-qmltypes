import QtQuick 2.6
import Sailfish.Silica 1.0

Row {
    id: root

    property date eventDate
    property bool showTime
    property bool timeContinued
    property bool useTwoLines: !fitsOneLine
    readonly property bool fitsOneLine: metrics.width < (maximumWidth - (timeText.visible ? (timeText.width + spacing) : 0))
    property alias font: timeText.font

    property real maximumWidth: parent.width

    property color color: Theme.highlightColor

    readonly property string _oneLineText: {
        var d = eventDate
        var result
        if (d.getFullYear() != (new Date).getFullYear()) {
            result = Format.formatDate(d, Format.DateFull)
        } else {
            result = Format.formatDate(d, Format.DateFullWithoutYear)
        }

        if (timeContinued && !showTime) {
            result += " -"
        }

        return result
    }

    spacing: Theme.paddingMedium

    TextMetrics {
        id: metrics
        font.pixelSize: Theme.fontSizeMedium
        text: _oneLineText
    }

    Column {
        Text {
            visible: useTwoLines
            font.pixelSize: Theme.fontSizeSmall
            color: root.color
            text: Format.formatDate(eventDate, Format.WeekdayNameStandalone)
        }
        Text {
            font: timeText.font
            color: root.color
            text: {
                if (useTwoLines) {
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
                } else {
                    return _oneLineText
                }
            }
        }
    }

    Text {
        id: timeText

        anchors.bottom: parent.bottom
        visible: showTime
        font.pixelSize: Theme.fontSizeMedium
        color: root.color
        text: Format.formatDate(eventDate, Formatter.TimeValue) + (timeContinued ? " -" : "")
    }
}
