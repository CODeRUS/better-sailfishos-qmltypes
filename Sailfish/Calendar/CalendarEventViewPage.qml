import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Calendar 1.0 as Calendar // QTBUG-27645
import org.nemomobile.calendar 1.0
import Nemo.DBus 2.0

Page {
    id: root

    property alias uniqueId: query.uniqueId
    property alias recurrenceId: query.recurrenceId
    property alias startTime: query.startTimeString

    EventQuery {
        id: query
        property string startTimeString
        onStartTimeStringChanged: {
            query.startTime = Calendar.CalendarUtils.parseTime(query.startTimeString)
        }
    }

    DBusInterface {
        id: calendarDBusInterface
        service: "com.jolla.calendar.ui"
        path: "/com/jolla/calendar/ui"
        iface: "com.jolla.calendar.ui"
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        PullDownMenu {
            visible: !!query.event && Calendar.CalendarUtils.calendarAppInstalled
            MenuItem {
                //% "Show in Calendar"
                text: qsTrId("sailfish_calendar-me-show_event_in_calendar")
                onClicked: {
                    calendarDBusInterface.call("viewEvent", [root.uniqueId, root.recurrenceId, root.startTime])
                }
            }
        }

        Column {
            id: column

            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                width: parent.width
                title: query.event ? query.event.displayLabel : ""
                wrapMode: Text.Wrap
            }

            CalendarEventView {
                id: eventDetails
                event: query.event
                occurrence: query.occurrence
                showHeader: false
                Connections {
                    target: query
                    onAttendeesChanged: {
                        eventDetails.setAttendees(query.attendees)
                    }
                }
            }
        }
        VerticalScrollDecorator {}
    }
}
