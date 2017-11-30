/****************************************************************************
**
** Copyright (C) 2017 Jolla Ltd.
** Contact: Chris Adams <chris.adams@jolla.com>
**
****************************************************************************/

import QtQuick 2.4
import Sailfish.Silica 1.0
import Sailfish.Calendar 1.0
import org.nemomobile.calendar.lightweight 1.0

BackgroundItem {
    id: delegate

    property int dateLabelPixelSize     // the size of the font used for date/time labels
    property real maxDateLabelWidth     // calculated via font metrics on long day names / time strings
    property real dateLabelLeftMargin   // the margin to use, left of the date/time labels
    property bool isToday               // whether the date of the event is today

    property real dateWidth: Math.max(dateLabel.implicitWidth, timeLabel.implicitWidth)

    CalendarColorBar {
        color: model.color
    }

    Label {
        id: timeLabel

        width: maxDateLabelWidth
        anchors {
            left: parent.left
            leftMargin: dateLabelLeftMargin
            bottom: parent.verticalCenter
        }
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font.pixelSize: dateLabelPixelSize
        //% "All day"
        text: allDay ? qsTrId("sailfish_calendar-la-all_day")
                     : Format.formatDate(startTime, Formatter.TimeValue)
        horizontalAlignment: Text.AlignRight
    }

    Label {
        id: dateLabel

        width: maxDateLabelWidth
        anchors {
            left: parent.left
            leftMargin: dateLabelLeftMargin
            top: timeLabel.bottom
        }
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font.pixelSize: dateLabelPixelSize
        //% "Today"
        text: isToday ? qsTrId("sailfish_calendar-la-today")
                      : Format.formatDate(startTime, Formatter.WeekdayNameStandalone)
        horizontalAlignment: Text.AlignRight
    }

    Label {
        id: nameLabel

        anchors {
            left: timeLabel.right
            leftMargin: Theme.paddingLarge
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: Theme.paddingLarge
        }
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
        text: displayLabel
        truncationMode: TruncationMode.Fade
    }
}
