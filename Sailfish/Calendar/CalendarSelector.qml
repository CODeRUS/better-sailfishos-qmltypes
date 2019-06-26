import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Calendar 1.0

BackgroundItem {
    id: root

    property alias accountIcon: calendarIcon.source
    property string name
    property alias description: description.text
    property alias color: colorBar.color
    property bool localCalendar

    width: parent ? parent.width : 0
    height: visible ? Math.max(Theme.itemSizeSmall, flow.height + Theme.paddingSmall*2) : 0
    opacity: enabled ? 1.0 : 0.4

    Flow {
        id: flow

        anchors {
            left: parent.left; right: colorBar.left; verticalCenter: parent.verticalCenter
            leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.paddingLarge
        }
        move: Transition { NumberAnimation { properties: "x,y"; easing.type: Easing.InOutQuad; duration: 200 } }

        Label {
            id: titleText

            color: (root.down || !root.enabled) ? Theme.highlightColor : Theme.primaryColor
            width: Math.min(implicitWidth + Theme.paddingMedium, parent.width)
            truncationMode: TruncationMode.Fade
            //: event calendar selection header
            //% "Calendar"
            text: qsTrId("calendar-la-calendar")
        }

        Column {
            width: Math.max(nameRow.width, description.width)

            Row {
                id: nameRow

                spacing: Theme.paddingMedium

                Image {
                    id: calendarIcon
                    height: Theme.iconSizeSmall
                    width: Theme.iconSizeSmall
                    anchors.verticalCenter: parent.verticalCenter
                    visible: source != ""
                }
                Label {
                    text: root.localCalendar ? CommonCalendarTranslations.getLocalCalendarName()
                                             : root.name

                    color: Theme.highlightColor
                    width: Math.min(implicitWidth, flow.width)
                    anchors.verticalCenter: parent.verticalCenter
                    truncationMode: TruncationMode.Fade
                    // JB#34057: Protect one line requirement from newline characters
                    maximumLineCount: 1
                }
            }

            Label {
                id: description

                color: Theme.highlightColor
                visible: text != ""
                width: Math.min(implicitWidth, flow.width)
                truncationMode: TruncationMode.Fade
                // JB#34057: Protect one line requirement from newline characters
                maximumLineCount: 1
            }
        }
    }

    Rectangle {
        id: colorBar

        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }

        height: parent.height - 2*Theme.paddingSmall
        radius: Math.round(width / 3)
        width: Theme.paddingSmall
    }
}
