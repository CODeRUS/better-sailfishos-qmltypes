/****************************************************************************
**
** Copyright (C) 2015 Jolla Ltd.
** Contact: Petri M. Gerdt <petri.gerdt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Calendar 1.0
import org.nemomobile.calendar.lightweight 1.0
import org.nemomobile.dbus 2.0
import org.nemomobile.time 1.0

Column {
    id: calendarWidget

    property bool enableUpdates
    property alias expiryDate: eventsModel.expiryDate
    property alias time: wallClock.time
    property date modelDate: new Date()
    property int eventDisplayTime: 900

    // In the future, these values should be passed in from the EventsView loader
    property real leftMargin: Theme.horizontalPageMargin
    property real rightMargin: Screen.sizeCategory >= Screen.Large ? Theme.paddingLarge : Theme.horizontalPageMargin

    function showEvent(uid, recurrenceId, startDate) {
        dbusInterface.call("viewEvent", [uid, recurrenceId, startDate]);
    }

    function viewToday() {
        dbusInterface.call("viewDate", (new Date()).toString());
    }

    onTimeChanged: {
        if (!isNaN(expiryDate.getTime())) {
            // TODO: check whether allDayModel needs updating
            if (time < eventsModel.creationDate || calendarWidget.expiryDate <= time) {
                calendarWidget.modelDate = time
            }
        }
    }

    height: implicitHeight
    spacing: Math.round(Theme.pixelRatio * (Screen.sizeCategory <= Screen.Medium ? 1 : 2))

    WallClock {
        id: wallClock

        enabled: enableUpdates && !isNaN(expiryDate.getTime())
        updateFrequency: WallClock.Minute
    }

    DBusInterface {
        id: dbusInterface

        service: "com.jolla.calendar.ui"
        path: "/com/jolla/calendar/ui"
        iface: "com.jolla.calendar.ui"
    }

    CalendarEventsModel {
        id: allDayModel

        startDate: calendarWidget.modelDate
        filterMode: CalendarEventsModel.FilterPast
        contentType: CalendarEventsModel.ContentAllDay
        eventLimit: 1
    }

    CalendarEventsModel {
        id: eventsModel

        startDate: calendarWidget.modelDate
        filterMode: CalendarEventsModel.FilterPast
        contentType: CalendarEventsModel.ContentEvents
        eventDisplayTime: calendarWidget.eventDisplayTime
        eventLimit: 2
    }

    Repeater {
        model: allDayModel
        delegate: BackgroundItem {
            width: calendarWidget.width
            height: Theme.itemSizeExtraSmall
            onClicked: moreLabel.visible
                       ? viewToday()
                       : showEvent(uid, recurrenceId, startTime)

            Item {
                width: parent.width
                height: parent.height

                ColorBar {
                    color: model.color
                }

                Label {
                    id: allDayLabel

                    property real maxContentWidth: parent.width - calendarWidget.leftMargin - calendarWidget.rightMargin
                    property real maxWidth: maxContentWidth - (moreLabel.visible ? moreLabel.width + Theme.paddingSmall : 0)

                    anchors {
                        left: parent.left
                        leftMargin: calendarWidget.leftMargin
                        verticalCenter: parent.verticalCenter
                    }
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: displayLabel
                    truncationMode: TruncationMode.Fade
                    width: Math.min(contentWidth, maxWidth)
                }

                Label {
                    id: moreLabel

                    property int moreCount: allDayModel.totalCount - allDayModel.count

                    visible: moreCount > 0

                    anchors {
                        baseline: allDayLabel.baseline
                        left: allDayLabel.right
                        leftMargin: Theme.paddingSmall
                    }
                    color: allDayLabel.color
                    font.pixelSize: Theme.fontSizeExtraSmall

                    //% "and %n more"
                    //: Added after an all day event label if more all
                    //: day events are available, %n indicates how many.
                    text: qsTrId("calendar-li-more_allday_events", moreCount)
                }
            }
        }
    }

    // Hidden label used to calculate the pixel width of a long time
    Label {
        id: hiddenTime

        visible: false
        font.pixelSize: Theme.fontSizeExtraSmall
        text: Format.formatDate(new Date(2015, 1, 1, 18, 59, 0), Formatter.TimeValue)
    }

    Repeater {
        model: eventsModel
        delegate: BackgroundItem {
            width: calendarWidget.width
            height: Theme.itemSizeExtraSmall
            onClicked: showEvent(uid, recurrenceId, startTime)

            Item {
                width: parent.width
                height: parent.height

                ColorBar {
                    color: model.color
                }

                Label {
                    id: timeLabel

                    width: hiddenTime.width
                    anchors {
                        left: parent.left
                        leftMargin: calendarWidget.leftMargin
                        baseline: nameLabel.baseline
                    }
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: hiddenTime.font.pixelSize
                    text: Format.formatDate(startTime, Formatter.TimeValue)
                    horizontalAlignment: Text.AlignRight
                }

                Label {
                    id: nameLabel

                    anchors {
                        left: timeLabel.right
                        leftMargin: Theme.paddingLarge
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: Theme.paddingLarge * 3
                    }
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                    text: displayLabel
                    truncationMode: TruncationMode.Fade
                }
            }
        }
    }
}
