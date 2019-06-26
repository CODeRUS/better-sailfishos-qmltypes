import QtQuick 2.6
import Sailfish.Silica 1.0

Item {
    id: dateSelector

    property bool allDay
    property bool showError

    property Item currentDialog
    property int startHour
    property int startMinute
    property int endHour
    property int endMinute
    property int startDay
    property int startMonth
    property int startYear
    property int endDay
    property int endMonth
    property int endYear

    // Note: doesn't take allDay into account
    readonly property date startDate: new Date(startYear, startMonth - 1, startDay, startHour, startMinute)
    readonly property date endDate: new Date(endYear, endMonth - 1, endDay, endHour, endMinute)

    // these two can be overridden for special date/time change logic. by default this allows end before start.
    function handleStartTimeModification(newStartTime, dateChange) {
        setStartDate(newStartTime)
    }

    function handleEndTimeModification(newEndTime, dateChange) {
        setEndDate(newEndTime)
    }

    function setStartDate(date) {
        startYear = date.getFullYear()
        startMonth = date.getMonth() + 1
        startDay = date.getDate()
        startHour = date.getHours()
        startMinute = date.getMinutes()
    }

    function setEndDate(date) {
        endYear = date.getFullYear()
        endMonth = date.getMonth() + 1
        endDay = date.getDate()
        endHour = date.getHours()
        endMinute = date.getMinutes()
    }

    width: parent.width
    height: Math.max(dateSelectorWidget.height, timeSelectorWidget.height)

    Component {
        id: timePicker
        TimePickerDialog {}
    }

    Component {
        id: datePicker
        DatePickerDialog {}
    }

    CalendarStartEndWidget {
        id: dateSelectorWidget

        x: Theme.horizontalPageMargin
        icon: "image://theme/icon-s-date?" + Theme.highlightColor
        error: showError
        //: Pattern for date and month, %1 is day, %2 is month
        //% "%1.%2"
        startText: qsTrId("sailfish_calendar-la-date_month_pattern").arg(dateSelector.startDay.toLocaleString()).arg(dateSelector.startMonth.toLocaleString())
        endText: qsTrId("sailfish_calendar-la-date_month_pattern").arg(dateSelector.endDay.toLocaleString()).arg(dateSelector.endMonth.toLocaleString())

        onStartClicked: {
            if (dateSelector.currentDialog)
                return
            var obj = pageStack.animatorPush(datePicker, { date: dateSelector.startDate })
            obj.pageCompleted.connect(function(dialog) {
                dateSelector.currentDialog = dialog
                dialog.accepted.connect(function() {
                    var newStart = new Date(dialog.year,
                                            dialog.month - 1,
                                            dialog.day,
                                            dateSelector.startHour,
                                            dateSelector.startMinute)

                    handleStartTimeModification(newStart, true)
                })
            })
        }

        onEndClicked: {
            if (dateSelector.currentDialog)
                return
            var obj = pageStack.animatorPush(datePicker, { date: dateSelector.endDate })
            obj.pageCompleted.connect(function(dialog) {
                dateSelector.currentDialog = dialog
                dialog.accepted.connect(function() {
                    var newEnd = new Date(dialog.year,
                                          dialog.month - 1,
                                          dialog.day,
                                          dateSelector.endHour,
                                          dateSelector.endMinute)

                    handleEndTimeModification(newEnd, true)
                })
            })
        }
    }

    CalendarStartEndWidget {
        id: timeSelectorWidget

        x: parent.width - width - Theme.horizontalPageMargin
        icon: "image://theme/icon-s-time?" + Theme.highlightColor
        error: showError
        startText: Format.formatDate(dateSelector.startDate, Formatter.TimeValue)
        endText: Format.formatDate(dateSelector.endDate, Formatter.TimeValue)

        onStartClicked: {
            var obj = pageStack.animatorPush(timePicker,
                                             {hour: dateSelector.startHour, minute: dateSelector.startMinute})
            obj.pageCompleted.connect(function(dialog) {
                dateSelector.currentDialog = dialog
                dialog.accepted.connect(function() {
                    var newStart = new Date(dateSelector.startYear,
                                            dateSelector.startMonth - 1,
                                            dateSelector.startDay,
                                            dialog.hour,
                                            dialog.minute)

                    handleStartTimeModification(newStart, false)
                })
            })
        }

        onEndClicked: {
            var obj = pageStack.animatorPush(timePicker,
                                             {hour: dateSelector.endHour, minute: dateSelector.endMinute})
            obj.pageCompleted.connect(function(dialog) {
                dateSelector.currentDialog = dialog
                dialog.accepted.connect(function() {
                    var newEnd = new Date(dateSelector.endYear,
                                          dateSelector.endMonth - 1,
                                          dateSelector.endDay,
                                          dialog.hour,
                                          dialog.minute)

                    handleEndTimeModification(newEnd, false)
                })
            })
        }
    }

    states: State {
        name: "timeHidden"
        when: allDay
        PropertyChanges { target: timeSelectorWidget; opacity: 0; enabled: false }
        PropertyChanges { target: dateSelectorWidget; x: (parent.width - width) / 2 }
    }
    transitions: Transition {
        NumberAnimation { properties: "opacity,x"; easing.type: Easing.InOutQuad }
    }
}
