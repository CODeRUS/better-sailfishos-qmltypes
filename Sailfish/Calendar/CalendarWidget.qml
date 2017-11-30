/****************************************************************************
**
** Copyright (C) 2015 Jolla Ltd.
** Contact: Petri M. Gerdt <petri.gerdt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.4
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
    property bool expanded
    property int shownEvents: expanded ? maximumEvents
                                       : (eventsModel.totalCount == 4 ? 4 : 3)
    property int maximumEvents: 6
    property int maximumDaysHence: 6 // less than one week to prevent ambiguity in weekday names
    property int eventDisplayTime: 900

    // In the future, these values should be passed in from the EventsView loader
    property real leftMargin: Theme.horizontalPageMargin
    property real rightMargin: Screen.sizeCategory >= Screen.Large ? Theme.paddingLarge : Theme.horizontalPageMargin
    property real maxDateLabelWidth

    height: implicitHeight

    function collapse() {
        // e.g. on screen blank or inactivity timeout
        collapseTimer.collapse()
    }

    function preventCollapse() {
        // e.g. on events view shown or peeked
        if (collapseTimer.running) {
            collapseTimer.stop()
        }
    }

    function showEvent(uid, recurrenceId, startDate) {
        dbusInterface.call("viewEvent", [uid, recurrenceId, Qt.formatDateTime(startDate, Qt.ISODate)])
    }

    function showCalendar(dateString) {
        dbusInterface.call("activateWindow", dateString)
    }

    onTimeChanged: {
        if (!isNaN(expiryDate.getTime())) {
            if (time < eventsModel.creationDate || calendarWidget.expiryDate <= time
                    || calendarWidget.modelDate.getDate() != time.getDate()
                    || calendarWidget.modelDate.getMonth() != time.getMonth()
                    || calendarWidget.modelDate.getFullYear() != time.getFullYear()) {
                calendarWidget.modelDate = time
            }
        }
    }

    // Used to calculate the pixel width of a long time
    TextMetrics {
        id: dateLabelMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeExtraSmall
        text: Format.formatDate(new Date(2015, 1, 1, 18, 59, 0), Formatter.TimeValue)
        onWidthChanged: dateLabelUpdater.restart()
    }

    WallClock {
        id: wallClock

        enabled: enableUpdates && !isNaN(expiryDate.getTime())
        updateFrequency: WallClock.Minute
    }

    Timer {
        id: collapseTimer
        onTriggered: collapse()
        function collapse() {
            collapseTimer.stop()
            calendarWidget.expanded = false
        }
    }

    Timer {
        id: dateLabelUpdater
        interval: 10
        onTriggered: {
            var max = dateLabelMetrics.width
            for (var i = 0; i < repeater.count; ++i) {
                max = Math.max(max, repeater.itemAt(i).dateWidth)
            }
            maxDateLabelWidth = max
        }
    }

    DBusInterface {
        id: dbusInterface

        service: "com.jolla.calendar.ui"
        path: "/com/jolla/calendar/ui"
        iface: "com.jolla.calendar.ui"
    }

    CalendarEventsModel {
        id: eventsModel

        startDate: calendarWidget.modelDate
        endDate: {
            var end = new Date()
            end.setDate(calendarWidget.modelDate.getDate() + calendarWidget.maximumDaysHence)
            return end
        }
        filterMode: CalendarEventsModel.FilterPast
        contentType: CalendarEventsModel.ContentAll
        eventDisplayTime: calendarWidget.eventDisplayTime
        eventLimit: calendarWidget.maximumEvents
    }

    Column {
        clip: true
        width: parent.width
        // spacing used also after last event
        height: Math.min(eventsModel.count, calendarWidget.shownEvents) * (Theme.itemSizeSmall + spacing)
        spacing: Math.round(Theme.pixelRatio * (Screen.sizeCategory <= Screen.Medium ? 1 : 2))

        Behavior on height { NumberAnimation { duration: 250 } }

        Repeater {
            id: repeater
            model: eventsModel
            onItemAdded: dateLabelUpdater.restart()
            onItemRemoved: dateLabelUpdater.restart()
            delegate: CalendarWidgetDelegate {
                width: calendarWidget.width
                dateLabelPixelSize: dateLabelMetrics.font.pixelSize
                maxDateLabelWidth: calendarWidget.maxDateLabelWidth
                dateLabelLeftMargin: calendarWidget.leftMargin
                // event started yesterday or earlier is still today on list
                isToday: startTime.getDate() == eventsModel.startDate.getDate()
                         || startTime < eventsModel.startDate
                onClicked: showEvent(uid, recurrenceId, startTime)
                opacity: index < calendarWidget.shownEvents ? 1.0 : 0.0
                Behavior on opacity { FadeAnimation { duration: 400 } }
            }
        }
    }

    BackgroundItem {
        id: showMoreItem

        property int showMoreCount: eventsModel.totalCount - calendarWidget.shownEvents

        enabled: showMoreCount > 0
        width: parent.width
        height: enabled ? Theme.itemSizeSmall : 0
        opacity: enabled ? 1.0 : 0.0
        visible: height > 0 && (calendarWidget.shownEvents != calendarWidget.maximumEvents || CalendarUtils.calendarAppInstalled)

        Behavior on height { NumberAnimation { duration: 250 } } // decrease in parallel with event list expansion

        Label {
            id: moreEventsLabel
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: calendarWidget.leftMargin
            }
            width: Math.min(implicitWidth, parent.width - x - Theme.paddingMedium*2 - moreEventsImg.width)
            height: Theme.itemSizeExtraSmall
            color: showMoreItem.highlighted ? Theme.highlightColor : Theme.primaryColor
            verticalAlignment: Text.AlignVCenter
            truncationMode: TruncationMode.Fade
            font.italic: true
            font.pixelSize: Theme.fontSizeExtraSmall

            //% "Show more"
            text: qsTrId("sailfish_calendar-la-show_more")
        }
        Image {
            id: moreEventsImg
            anchors {
                verticalCenter: parent.verticalCenter
                left: moreEventsLabel.right
                leftMargin: Theme.paddingMedium
            }
            source: "image://theme/icon-lock-more?" + (showMoreItem.highlighted ? Theme.highlightColor : Theme.primaryColor)
            width: Theme.iconSizeMedium * 0.7
            height: width
            sourceSize.width: width
        }

        onClicked: {
            if (!calendarWidget.expanded) {
                // expand the view to include the other events
                calendarWidget.expanded = true
            } else {
                // open up the calendar application and de-expand the view
                showCalendar(calendarWidget.modelDate.toString())
                collapseTimer.interval = 1000
                collapseTimer.start()
            }
        }
    }
}
