/****************************************************************************
**
** Copyright (C) 2015 Jolla Ltd.
** Contact: Petri M. Gerdt <petri.gerdt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Calendar 1.0 as Calendar // QTBUG-27645
import org.nemomobile.calendar.lightweight 1.0
import org.nemomobile.dbus 2.0
import org.nemomobile.time 1.0

Column {
    id: calendarWidget

    property bool enableUpdates
    property bool deviceLocked
    property alias expiryDate: eventsModel.expiryDate
    property alias time: wallClock.time
    property date modelDate: new Date()
    property bool expanded
    property int shownEvents: expanded ? maximumEvents
                                       : (eventsModel.totalCount == 4 ? 4 : 3)
    property int maximumEvents: 6
    property int maximumDaysHence: 6 // less than one week to prevent ambiguity in weekday names
    property int eventDisplayTime: 900

    property int labelLeftMargin: icon.x + icon.width + Theme.paddingMedium + Theme.paddingSmall
    property real rightMargin: Screen.sizeCategory >= Screen.Large ? Theme.paddingLarge : Theme.horizontalPageMargin
    property real maxTimeLabelWidth

    signal requestUnlock
    signal checkPendingAction
    signal cancelPendingAction

    height: implicitHeight
    clip: heightAnimation.running
    Behavior on height { NumberAnimation { id: heightAnimation; easing.type: Easing.InOutQuad; duration: 200 } }

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
        id: timeLabelMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        text: Format.formatDate(new Date(2015, 1, 1, 18, 59, 0), Formatter.TimeValue)
        onWidthChanged: timeLabelUpdater.restart()
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
        id: timeLabelUpdater
        interval: 10
        onTriggered: {
            var max = timeLabelMetrics.width
            for (var i = 0; i < repeater.count; ++i) {
                max = Math.max(max, repeater.itemAt(i).timeWidth)
            }
            maxTimeLabelWidth = max
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

    Item {
        visible: eventsModel.count > 0
        HighlightImage {
            id: icon
            source: "image://theme/icon-lock-calendar"
            x: Theme.horizontalPageMargin
        }
    }

    Repeater {
        id: repeater
        model: eventsModel
        onItemAdded: timeLabelUpdater.restart()
        onItemRemoved: timeLabelUpdater.restart()
        delegate: Column {
            property alias dateLabel: delegate.dateLabel
            property alias timeWidth: delegate.timeWidth
            property bool active: model.index < calendarWidget.shownEvents
            property Item previousItem: repeater.itemAt(model.index - 1)
            property bool showHeader: model.index === 0 || (previousItem && previousItem.dateLabel !== dateLabel)
            property bool actionPending // action postponed until device is unlocked

            enabled: active
            width: parent.width
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { FadeAnimator {} }
            height: active ? implicitHeight : 0
            topPadding: model.index !== 0 && showHeader ? Theme.paddingMedium : 0

            Label {
                visible: showHeader
                x: labelLeftMargin
                width: parent.width - x
                truncationMode: TruncationMode.Fade
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
                text: showHeader ? dateLabel : ""
            }

            CalendarWidgetDelegate {
                id: delegate
                labelLeftMargin: calendarWidget.labelLeftMargin
                pixelSize: timeLabelMetrics.font.pixelSize
                maxTimeLabelWidth: calendarWidget.maxTimeLabelWidth
                // event started yesterday or earlier is still today on list
                isToday: startTime.getDate() == eventsModel.startDate.getDate()
                         || startTime < eventsModel.startDate

                onClicked: {
                    if (calendarWidget.deviceLocked) {
                        calendarWidget.requestUnlock()
                        actionPending = true
                    } else {
                        showEvent(uid, recurrenceId, startTime)
                    }
                }

                Connections {
                    target: calendarWidget
                    onCheckPendingAction: {
                        if (actionPending) {
                            calendarWidget.showEvent(uid, recurrenceId, startTime)
                            actionPending = false
                        }
                    }
                    onCancelPendingAction: actionPending = false
                }
            }
        }
    }

    BackgroundItem {
        id: showMoreItem

        property int showMoreCount: eventsModel.totalCount - calendarWidget.shownEvents
        property bool actionPending

        enabled: showMoreCount > 0
        width: parent.width
        height: enabled ? moreEventsLabel.height + 2*Theme.paddingMedium : 0
        opacity: enabled ? 1.0 : 0.0
        visible: calendarWidget.shownEvents != calendarWidget.maximumEvents || Calendar.CalendarUtils.calendarAppInstalled

        Label {
            id: moreEventsLabel
            anchors {
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -Theme.paddingSmall
            }
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeExtraSmall

            //% "Show more..."
            text: qsTrId("sailfish_calendar-la-show_more")
        }

        onClicked: {
            if (!calendarWidget.expanded) {
                // expand the view to include the other events
                calendarWidget.expanded = true
            } else {
                if (calendarWidget.deviceLocked) {
                    calendarWidget.requestUnlock()
                    actionPending = true
                } else {
                    showCalendar()
                }
            }
        }

        function showCalendar() {
            // open up the calendar application and de-expand the view
            calendarWidget.showCalendar(calendarWidget.modelDate.toString())
            collapseTimer.interval = 1000
            collapseTimer.start()

        }

        Connections {
            target: calendarWidget
            onCheckPendingAction: {
                if (showMoreItem.actionPending) {
                    showMoreItem.showCalendar()
                    showMoreItem.actionPending = false
                }
            }
            onCancelPendingAction: showMoreItem.actionPending = false
        }
    }
}
