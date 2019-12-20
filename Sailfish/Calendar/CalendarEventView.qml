import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TextLinking 1.0
import org.nemomobile.calendar 1.0
import Sailfish.Calendar 1.0 as Calendar
import org.nemomobile.notifications 1.0 as SystemNotifications

Column {
    id: root

    property QtObject event
    property QtObject occurrence
    property alias showDescription: descriptionText.visible
    property alias showHeader: eventHeader.visible
    property bool showSelector: !showHeader // by default, show calendar selector if colored header is not visible

    function setAttendees(attendeeList) {
        attendeeView.model = attendeeList
    }

    width: parent.width
    visible: root.event
    spacing: Theme.paddingMedium

    Item {
        id: eventHeader
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

            readonly property bool twoLineDates: !startDate.fitsOneLine || !endDate.fitsOneLine
            readonly property bool multiDay: {
                if (!root.occurrence) {
                    return false
                }

                var start = root.occurrence.startTime
                var end = root.occurrence.endTime
                return start.getFullYear() !== end.getFullYear()
                        || start.getMonth() !== end.getMonth()
                        || start.getDate() !== end.getDate()
            }

            width: parent.width - (recurrenceIcon.visible ? recurrenceIcon.width : 0)

            CalendarEventDate {
                id: startDate

                eventDate: root.occurrence ? root.occurrence.startTime : new Date(-1)
                showTime: parent.multiDay && (root.event && !root.event.allDay)
                timeContinued: parent.multiDay
                useTwoLines: timeColumn.twoLineDates
            }

            CalendarEventDate {
                id: endDate

                visible: parent.multiDay
                eventDate: root.occurrence ? root.occurrence.endTime : new Date(-1)
                showTime: root.event && !root.event.allDay
                useTwoLines: timeColumn.twoLineDates
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
        Image {
            id: recurrenceIcon
            visible: root.event && root.event.recur !== CalendarEvent.RecurOnce
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            source: "image://theme/icon-s-sync?" + Theme.highlightColor
        }
    }

    Item {
        // reminderRow
        width: parent.width - 2*Theme.horizontalPageMargin
        height: reminderText.height
        x: Theme.horizontalPageMargin
        visible: root.event && root.event.reminder >= 0

        Label {
            id: reminderText
            width: parent.width - reminderIcon.width
            anchors.left: parent.left
            color: Theme.highlightColor
            wrapMode: Text.WordWrap
            //: %1 gets replaced with reminder time, e.g. "15 minutes before"
            //% "Reminder %1"
            text: root.event ? qsTrId("sailfish_calendar-view-reminder")
                               .arg(Calendar.CommonCalendarTranslations.getReminderText(root.event.reminder))
                             : ""
        }
        Image {
            id: reminderIcon
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }
            source: "image://theme/icon-s-alarm?" + Theme.highlightColor
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
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: root.event ? root.event.location : ""
            }
        }

        Loader {
            active: event && event.rsvp
            width: parent.width
            sourceComponent: Item {
                width: parent.width
                height: responseButtons.height + responseButtons.anchors.topMargin + Theme.paddingMedium
                InvitationResponseButtons {
                    id: responseButtons
                    width: parent.width
                    anchors.top: parent.top
                    anchors.topMargin: Theme.paddingMedium
                    responseState: event ? event.ownerStatus : CalendarEvent.ResponseUnspecified
                    enabled: !disableTimer.running
                    onResponseStateChanged: {
                        disableTimer.stop()
                    }

                    onCalendarInvitationResponded: {
                        var res = root.event.sendResponse(response)
                        disableTimer.start()
                        if (!res) {
                            var previewText
                            switch (response) {
                            case CalendarEvent.ResponseAccept:
                                //: Failed to send invitation response (accept)
                                //% "Failed to accept invitation"
                                previewText = qsTrId("sailfish_calendar-la-response_failed_body_accept")
                                break
                            case CalendarEvent.ResponseTentative:
                                //: Failed to send invitation response (tentative)
                                //% "Failed to tentatively accept invitation"
                                previewText = qsTrId("sailfish_calendar-la-response_failed_body_tentative")
                                break
                            case CalendarEvent.ResponseDecline:
                                //: Failed to send invitation response (decline)
                                //% "Failed to decline invitation"
                                previewText = qsTrId("sailfish_calendar-la-la-response_failed_body_decline")
                                break
                            default:
                                break
                            }
                            if (previewText.length > 0) {
                                systemNotification.previewBody = previewText
                                systemNotification.publish()
                            }
                        }
                    }
                }
                Timer {
                    id: disableTimer
                    interval: 5000
                    repeat: false
                }
                SystemNotifications.Notification {
                    id: systemNotification

                    icon: "icon-lock-calendar"
                    isTransient: true
                }
            }
        }

        Column {
            id: attendees

            width: parent.width - 2*x
            x: Theme.horizontalPageMargin
            spacing: Theme.paddingMedium
            visible: attendeeView.count > 0

            Row {
                spacing: Theme.paddingMedium
                Image {
                    id: attendeeIcon
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/icon-m-people"
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    width: attendees.width - attendeeIcon.width - spacing
                    //% "%n people"
                    text: qsTrId("sailfish_calendar-la-people_count", attendeeView.count)
                }
            }

            ColumnView {
                id: attendeeView

                itemHeight: Theme.itemSizeSmall
                delegate: Item {
                    width: attendees.width
                    height: Theme.itemSizeSmall
                    Row {
                        spacing: Theme.paddingMedium
                        anchors.verticalCenter: parent.verticalCenter
                        Label {
                            id: nameLabel

                            text: modelData.name.length > 0 ? modelData.name : modelData.email
                            width: Math.min(implicitWidth,
                                            attendeeView.width - (statusIcon.source.length > 0
                                                                  ? statusIcon.width + Theme.paddingMedium : 0)
                                            - (extraText.text.length > 0 ? (extraText.width + parent.spacing) : 0))
                            truncationMode: TruncationMode.Fade
                        }
                        Label {
                            id: extraText

                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.baseline: nameLabel.baseline
                            text: modelData.isOrganizer ? //% "organizer"
                                                          qsTrId("sailfish_calendar-la-event_organizer")
                                                        : modelData.participationRole == Person.OptionalParticipant
                                                          ? //% "optional"
                                                            qsTrId("sailfish-calendar-la-event_optional_attendee")
                                                          : ""
                        }
                    }
                    HighlightImage {
                        id: statusIcon

                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        highlighted: true
                        source: modelData.participationStatus == Person.AcceptedParticipation
                                ? "image://theme/icon-s-accept"
                                : modelData.participationStatus == Person.DeclinedParticipation
                                  ? "image://theme/icon-s-decline"
                                  : modelData.participationStatus == Person.TentativeParticipation
                                    ? "image://theme/icon-s-maybe"
                                    : ""
                    }
                }
            }
        }

        SectionHeader {
            visible: descriptionText.visible && descriptionText.text != ""
            //% "Description"
            text: qsTrId("sailfish_calendar-he-event_description")
        }

        LinkedText {
            id: descriptionText

            width: parent.width - 2*Theme.horizontalPageMargin
            x: Theme.horizontalPageMargin
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
            plainText: root.event ? root.event.description : ""
        }
    }

    CalendarSelector {
        name: query.isValid ? query.name : ""
        localCalendar: query.localCalendar
        description: query.isValid ? query.description : ""
        color: query.isValid ? query.color : "transparent"
        accountIcon: query.isValid ? query.accountIcon : ""
        enabled: false
        opacity: 1.0
        visible: showSelector
        NotebookQuery {
            id: query
            targetUid: (root.event && root.event.calendarUid) ? root.event.calendarUid : ""
        }
    }
}

