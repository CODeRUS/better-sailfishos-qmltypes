.pragma library
.import org.nemomobile.calendar 1.0 as NemoCalendar

function getReminderText(reminder) {
    if (reminder < 0) {
        //% "Never"
        return qsTrId("sailfish_calendar-reminder-never")
    } else if (reminder == 0) {
        //% "At time of event"
        return qsTrId("sailfish_calendar-reminder-at_time_of_event")
    } else {
        return customReminderTranslationText(reminder)
    }
}

function customReminderTranslationText(reminder) {
    var secondsPerHour = 60 * 60
    var secondsPerDay = 24 * secondsPerHour
    var days = Math.floor(reminder / (secondsPerDay))
    var hours = Math.floor((reminder % (secondsPerDay)) / (secondsPerHour))
    var minutes = Math.floor((reminder % (secondsPerHour)) / 60)
    // var seconds = reminder % 60 // currently unused.

    //: e.g. '5 days', count of days prior to event start.  Fragment of "<X days>, <Y hours>, <Z minutes> before".
    //% "%n days"
    var daysStr = qsTrId("sailfish_calendar-reminder-n_days", days)
    //: e.g. '5 hours', count of hours prior to event start.  Fragment of "<X days>, <Y hours>, <Z minutes> before".
    //% "%n hours"
    var hoursStr = qsTrId("sailfish_calendar-reminder-n_hours", hours)
    //: e.g. '5 minutes', count of minutes prior to event start.  Fragment of "<X days>, <Y hours>, <Z minutes> before".
    //% "%n minutes"
    var minutesStr = qsTrId("sailfish_calendar-reminder-n_minutes", minutes)

    if (days > 0) {
        if (hours > 0) {
            if (minutes > 0) {
                //: Where %1 is "x days", %2 is "y hours", %3 is "z minutes"
                //% "%1, %2, %3 before"
                return qsTrId("sailfish_calendar-reminder-days_hours_minutes_before").arg(daysStr).arg(hoursStr).arg(minutesStr)
            } else {
                //: Where %1 is "x days", %2 is "y hours"
                //% "%1, %2 before"
                return qsTrId("sailfish_calendar-reminder-days_hours_before").arg(daysStr).arg(hoursStr)
            }
        } else if (minutes > 0) {
            //: Where %1 is "x days", %2 is "y minutes"
            //% "%1, %2 before"
            return qsTrId("sailfish_calendar-reminder-days_minutes_before").arg(daysStr).arg(minutesStr)
        } else {
            //% "%n days before"
            return qsTrId("sailfish_calendar-reminder-days_before", days)
        }
    } else if (hours > 0) {
        if (minutes > 0) {
            //: Where %1 "x hours", %2 is "y minutes"
            //% "%1, %2 before"
            return qsTrId("sailfish_calendar-reminder-hours_minutes_before").arg(hoursStr).arg(minutesStr)
        } else {
            //% "%n hours before"
            return qsTrId("sailfish_calendar-reminder-hours_before", hours)
        }
    } else {
        //% "%n minutes before"
        return qsTrId("sailfish_calendar-reminder-minutes_before", minutes)
    }
}

function getLocalCalendarName() {
    //: Personal calendar name.
    //% "Personal"
    return qsTrId("sailfish_calendar-la-personal_calendar_name")
}
