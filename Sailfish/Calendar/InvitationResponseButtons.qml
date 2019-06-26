import QtQuick 2.2
import Sailfish.Silica 1.0
import org.nemomobile.calendar 1.0

Column {
    id: root
    spacing: Theme.paddingMedium

    property int responseState: CalendarEvent.ResponseUnspecified
    property string subject
    property color _color: Theme.primaryColor
    property color _selectedColor: Theme.highlightColor

    signal calendarInvitationResponded(int response, string responseSubject)

    Label {
        x: Theme.horizontalPageMargin
        width: parent.width - 2*x
        color: Theme.highlightColor
        text: {
            switch (root.responseState) {
            case CalendarEvent.ResponseAccept:
                //! Question to attend invitation. User already selected "Yes" before
                //% "Attending? Yes"
                return qsTrId("sailfish_calendar-la-event_attending_question_yes")
            case CalendarEvent.ResponseTentative:
                //! Question to attend invitation. User already selected "Maybe" before
                //% "Attending? Maybe"
                return qsTrId("sailfish_calendar-la-event_attending_question_maybe")
            case CalendarEvent.ResponseDecline:
                //! Question to attend invitation. User already selected "No" before
                //% "Attending? No"
                return qsTrId("sailfish_calendar-la-event_attending_question_no")
            default:
                //! Question to attend invitation. Displayed together with "Yes", "Maybe" and "No" buttons
                //% "Attending?"
                return qsTrId("sailfish_calendar-la-event_attending_question")
            }
        }
        elide: Text.ElideRight
    }

    ButtonLayout {
        preferredWidth: Theme.buttonWidthExtraSmall
        width: parent.width

        Button {
            color: root.responseState === CalendarEvent.ResponseAccept ?
                       root._selectedColor : root._color
            enabled: root.enabled
            //: Yes calendar invitation button. Shall be short to fit in 1 row
            //% "Yes"
            text: qsTrId("sailfish_calendar-la-event_attendbutton_yes")
            onClicked: {
                //: Subject modifier for accept response. %1 is original invitation subject
                //% "Accepted: %1"
                var newSubject = qsTrId("sailfish_calendar-la-event-subj_accept").arg(subject)
                if (root.responseState !== CalendarEvent.ResponseAccept) {
                    root.calendarInvitationResponded(CalendarEvent.ResponseAccept, newSubject)
                }
            }
        }
        Button {
            color: root.responseState === CalendarEvent.ResponseTentative ?
                       root._selectedColor : root._color
            enabled: root.enabled
            //: Maybe calendar invitation button. Shall be short to fit in 1 row
            //% "Maybe"
            text: qsTrId("sailfish_calendar-la-event_attendbutton_maybe")
            onClicked: {
                //: Subject modifier for tentative response. %1 is original invitation subject
                //% "Tentative: %1"
                var newSubject = qsTrId("sailfish_calendar-la-event-subj_tentative").arg(subject)
                if (root.responseState !== CalendarEvent.ResponseTentative) {
                    root.calendarInvitationResponded(CalendarEvent.ResponseTentative, newSubject)
                }
            }
        }
        Button {
            color: root.responseState === CalendarEvent.ResponseDecline ?
                       root._selectedColor : root._color
            enabled: root.enabled
            //: "No" calendar invitation button. Shall be short to fit in 1 row
            //% "No"
            text: qsTrId("sailfish_calendar-la-event_attendbutton_no")
            onClicked: {
                //: Subject modifier for decline response. %1 is original invitation subject
                //% "Declined: %1"
                var newSubject = qsTrId("sailfish_calendar-la-event-subj_declined").arg(subject)
                if (root.responseState !== CalendarEvent.ResponseDecline) {
                    root.calendarInvitationResponded(CalendarEvent.ResponseDecline, newSubject)
                }
            }
        }
    }
}
