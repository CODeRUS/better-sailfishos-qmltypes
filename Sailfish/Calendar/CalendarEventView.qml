import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Calendar 1.0
import Sailfish.TextLinking 1.0
import org.nemomobile.calendar 1.0

Column {
    id: root

    property QtObject event
    property QtObject occurrence

    function setAttendees(attendeeList) {
        var newOrganizer = ""
        var newMandatory = ""
        var newOptional = ""

        for (var i = 0; i < attendeeList.length; ++i)  {
            var attendee = attendeeList[i]

            if (attendee.isOrganizer) {
                newOrganizer = attendee.name
            } else if (attendee.participationRole == Person.RequiredParticipant) {
                if (newMandatory !== "") {
                    newMandatory = newMandatory + ", "
                }
                newMandatory = newMandatory + attendee.name
            } else if (attendee.participationRole == Person.OptionalParticipant) {
                if (newOptional !== "") {
                    newOptional = newOptional + ", "
                }
                newOptional = newOptional + attendee.name
            }
        }

        attendees.organizer = newOrganizer
        attendees.mandatoryAttendees = newMandatory
        attendees.optionalAttendees = newOptional
    }

    width: parent.width
    visible: root.event
    spacing: Theme.paddingMedium

    Item {
        height: displayLabel.height
        width: parent.width - 2*Theme.horizontalPageMargin
        x: Theme.horizontalPageMargin

        Rectangle {
            id: notebookRect
            width: Theme.paddingSmall
            radius: Math.round(width/3)
            color: root.event ? root.event.color : "transparent"
            height: parent.height
        }

        Label {
            id: displayLabel
            anchors {
                left: notebookRect.right
                leftMargin: Theme.paddingMedium
                right: parent.right
                rightMargin: Theme.paddingMedium
            }
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
            maximumLineCount: 5
            wrapMode: Text.WordWrap
            text: root.event ? root.event.displayLabel : ""
            truncationMode: TruncationMode.Fade
        }
    }

    Item {
        height: timeColumn.height
        width: parent.width - 2*Theme.horizontalPageMargin
        x: Theme.horizontalPageMargin

        Column {
            id: timeColumn

            property bool multiDay: {
                if (!root.occurrence) {
                    return false
                }

                var start = root.occurrence.startTime
                var end = root.occurrence.endTime
                return start.getFullYear() !== end.getFullYear()
                        || start.getMonth() !== end.getMonth()
                        || start.getDate() !== end.getDate()
            }

            CalendarEventDate {
                eventDate: root.occurrence ? root.occurrence.startTime : new Date(-1)
                showTime: parent.multiDay && (root.event && !root.event.allDay)
                timeContinued: parent.multiDay
            }

            Item {
                visible: parent.multiDay
                width: parent.width
                height: Theme.paddingLarge
            }

            CalendarEventDate {
                visible: parent.multiDay
                eventDate: root.occurrence ? root.occurrence.endTime : new Date(-1)
                showTime: root.event && !root.event.allDay
            }

            Text {
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                visible: !parent.multiDay
                //% "All day"
                text: root.event ? (root.event.allDay ? qsTrId("sailfish_calendar-la-all_day")
                                                      : (Format.formatDate(root.occurrence.startTime, Formatter.TimeValue)
                                                         + " - "
                                                         + Format.formatDate(root.occurrence.endTime, Formatter.TimeValue))
                                    )
                                 : ""
            }
        }
        Row {
            anchors.right: parent.right
            height: parent.height
            Image {
                visible: root.event && root.event.reminder != CalendarEvent.ReminderNone
                anchors.verticalCenter: parent.verticalCenter
                source: "image://theme/icon-s-alarm?" + Theme.highlightColor
            }
            Image {
                visible: root.event && root.event.recur != CalendarEvent.RecurOnce
                anchors.verticalCenter: parent.verticalCenter
                source: "image://theme/icon-s-sync?" + Theme.highlightColor
            }
        }
    }

    Column {
        width: parent.width
        spacing: Theme.paddingMedium

        Item {
            visible: root.event && root.event.location !== ""
            width: parent.width - 2*Theme.horizontalPageMargin
            height: Math.max(locationIcon.height, locationText.height)
            x: Theme.horizontalPageMargin

            Image {
                id: locationIcon
                source: "image://theme/icon-m-location"
            }

            Label {
                id: locationText

                width: parent.width - locationIcon.width
                height: contentHeight
                x: locationIcon.width
                anchors.top: lineCount > 1 ? parent.top : undefined
                anchors.verticalCenter: lineCount > 1 ? undefined : locationIcon.verticalCenter
                opacity: 0.7
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: root.event ? root.event.location : ""
            }
        }

        Item {
            id: attendees

            property string organizer
            property string mandatoryAttendees
            property string optionalAttendees

            visible: organizer.length > 0 || mandatoryAttendees.length > 0 || optionalAttendees.length > 0
            width: parent.width - 2*Theme.horizontalPageMargin
            height: Math.max(attendeeIcon.height, attendeeInfo.height)
            x: Theme.horizontalPageMargin

            Image {
                id: attendeeIcon
                source: "image://theme/icon-m-people"
            }

            Column {
                id: attendeeInfo

                width: parent.width - attendeeIcon.width
                x: attendeeIcon.width
                spacing: Theme.paddingSmall

                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    opacity: 0.7
                    visible: attendees.organizer != ""
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                    textFormat: Text.StyledText
                    //% "Organizer:"
                    text: "<font size='4'>" + qsTrId("sailfish_calendar-la-event_organizer") + "</font> "
                          + attendees.organizer
                }

                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    opacity: 0.7
                    visible: attendees.mandatoryAttendees != ""
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                    textFormat: Text.StyledText
                    //% "Mandatory:"
                    text: "<font size='4'>" + qsTrId("sailfish_calendar-la-event_mandatory_attendees") + "</font> "
                          + attendees.mandatoryAttendees
                }

                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    opacity: 0.7
                    visible: attendees.optionalAttendees != ""
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                    textFormat: Text.StyledText
                    //% "Optional:"
                    text: "<font size='4'>" + qsTrId("sailfish-calendar-la-event_optional_attendees") +"</font> "
                          + attendees.optionalAttendees
                }

            }
        }

        SectionHeader {
            visible: descriptionText.text != ""
            //% "Description:"
            text: qsTrId("sailfish_calendar-he-event_description")
        }

        LinkedText {
            id: descriptionText

            width: parent.width - 2*Theme.horizontalPageMargin
            x: Theme.horizontalPageMargin
            opacity: 0.7
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
            plainText: root.event ? root.event.description : ""
        }
    }
}

