import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import Sailfish.Telephony 1.0
import org.nemomobile.contacts 1.0
import org.nemomobile.commhistory 1.0
import "common/common.js" as ContactsUtils

SilicaListView {
    id: root

    property Person contact
    property int limit
    property bool ready: contactEventModel.ready
    property bool hasMore: limit > 0 && count > limit
    property QtObject contactEventModel: contactEventModel
    property real leftMargin: Theme.horizontalPageMargin - Theme.paddingLarge + missedCallIcon.width

    property bool _animationEnabled: contactEventModel.ready
    property var _dateThreshold

    signal startPhoneCall(string number, string modemPath)
    signal startSms(string number)
    signal startInstantMessage(string localUid, string remoteUid)

    Component.onCompleted: {
        // The threshold for date format is 365 days before the current day began
        var today = new Date()
        var midnight = new Date(today.getFullYear(), today.getMonth(), today.getDate())
        _dateThreshold = midnight.valueOf() - (365 * 24 * 60 * 60 * 1000)
    }

    width: parent.width

    model: contactEventModel

    CommContactEventModel {
        id: contactEventModel
        contactId: root.contact.id
        limit: root.limit > 0 ? root.limit + 1 : 0
    }

    Image {
        // Load the missed call icon to layout delegates correctly
        id: missedCallIcon
        source: "image://theme/icon-phone-missed-call"
        visible: false
    }

    delegate: ListItem {
        id: eventItem

        property bool isPhone: localUid.indexOf('/ring/tel/') >= 0
        property bool isMessage: (eventType != CommCallModel.CallEvent) && (eventType != CommCallModel.VoicemailEvent)
        property string iconSource: isMessage ? "image://theme/icon-launcher-messaging" : "image://theme/icon-launcher-phone"
        property string directionIconSource: direction === CommCallModel.Inbound ? (isMissedCall ? "image://theme/icon-phone-missed-call" : "image://theme/icon-phone-incoming-call") : ''

        width: root.width
        contentHeight: Theme.itemSizeMedium
        visible: root.limit <= 0 || index < root.limit

        Binding {
            when: eventItem.highlighted
            target: root
            property: '_animationEnabled'
            value: false
        }

        Image {
            id: typeIcon

            anchors {
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
                verticalCenter: parent.verticalCenter
            }

            // use app icons, scaled to half their size
            width: visible ? Theme.itemSizeMedium / 2 : 0
            height: Theme.itemSizeMedium / 2
            source: iconSource
            visible: iconSource != ''
        }
        Label {
            id: dateLabel

            anchors {
                right: typeIcon.left
                rightMargin: Theme.paddingMedium
                baseline: eventTypeLabel.baseline
            }

            text: Format.formatDate(endTime, (endTime.valueOf() < _dateThreshold ? Format.DateMedium : Format.DateMediumWithoutYear))
            font.pixelSize: Theme.fontSizeExtraSmall
            color: highlighted ? Theme.highlightColor: Theme.primaryColor
            textFormat: Text.PlainText
        }
        Label {
            id: timestampLabel

            anchors {
                top: dateLabel.bottom
                topMargin: Theme.paddingSmall
                right: typeIcon.left
                rightMargin: Theme.paddingMedium
            }

            text: Format.formatDate(endTime, Format.TimeValue)
            font.pixelSize: Theme.fontSizeExtraSmall
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            textFormat: Text.PlainText
        }
        Image {
            id: directionIcon

            anchors {
                left: parent.left
                leftMargin: Theme.horizontalPageMargin - Theme.paddingLarge
                top: eventTypeLabel.top
            }
            source: directionIconSource ? directionIconSource + "?" + (highlighted ? Theme.highlightColor: Theme.primaryColor) : ''
            visible: directionIconSource != ''
        }
        Label {
            id: eventTypeLabel

            anchors {
                left: parent.left
                leftMargin: root.leftMargin
                right: dateLabel.left
                rightMargin: Theme.paddingMedium
                bottom: parent.verticalCenter
            }
            text: {
                if (isMessage) {
                    var messageText
                    if (freeText) {
                        messageText = freeText
                    } else if (subject) {
                        messageText = subject
                    } else if (eventType == CommHistory.MMSEvent) {
                        //% "Multimedia message"
                        messageText = qsTrId("components_contacts-la-multimedia_message")
                    } else {
                        //% "Message"
                        messageText = qsTrId("components_contacts-la-message")
                    }
                    return messageText
                } else {
                    if (direction === CommCallModel.Outbound) {
                        //% "Outgoing phone call"
                        return qsTrId("components_contacts-la-outgoing_call")
                    } else {
                                              //% "Missed phone call"
                        return isMissedCall ? qsTrId("components_contacts-la-missed_call")
                                              //% "Received phone call"
                                            : qsTrId("components_contacts-la-received_call")
                    }
                }
            }
            font.pixelSize: Theme.fontSizeSmall
            color: highlighted ? Theme.highlightColor: Theme.primaryColor
            truncationMode: TruncationMode.Fade
            textFormat: Text.PlainText
            maximumLineCount: 1
        }
        Label {
            anchors {
                top: eventTypeLabel.bottom
                topMargin: Theme.paddingSmall
                left: eventTypeLabel.left
                right: timestampLabel.left
                rightMargin: Theme.paddingMedium
            }
            text: {
                if (isPhone) {
                    return ContactsUtils.descriptionForPhoneNumber(root.contact, Person.normalizePhoneNumber(remoteUid), Person.minimizePhoneNumber(remoteUid), Person)
                } else {
                    return ContactsUtils.descriptionForAccountUri(root.contact, localUid, remoteUid, Person)
                }
            }
            font.pixelSize: Theme.fontSizeExtraSmall
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            truncationMode: TruncationMode.Fade
            textFormat: Text.PlainText
        }

        onClicked: openMenu()

        menu: Component {
            ContextMenu {
                id: contextMenu

                SimPickerMenuItem {
                    id: simPicker
                    menu: contextMenu
                    onTriggerAction: root.startPhoneCall(remoteUid, modemPath)
                }

                Item {
                    width: 1
                    height: Theme.paddingSmall
                }
                Row {
                    spacing: Theme.paddingSmall
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: Theme.itemSizeExtraSmall - Theme.paddingLarge - Theme.paddingSmall
                    Label {
                        color: Theme.secondaryHighlightColor
                        font.pixelSize: Theme.fontSizeSmall
                        width: Math.min(implicitWidth, eventItem.width - Theme.horizontalPageMargin*2 - durationIcon.width - durationLabel.width - 2*parent.spacing)
                        anchors.verticalCenter: parent.verticalCenter
                        truncationMode: TruncationMode.Fade
                        text: model.remoteUid
                    }
                    Image {
                        id: durationIcon
                        visible: !isMessage && !model.isMissedCall
                        source: "image://theme/icon-s-duration?" + Theme.highlightColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        id: durationLabel

                        property int duration: (model.endTime.valueOf()-model.startTime.valueOf())/1000

                        visible: !isMessage && !model.isMissedCall
                        color: Theme.secondaryHighlightColor
                        font.pixelSize: Theme.fontSizeSmall
                        anchors.verticalCenter: parent.verticalCenter
                        text: Format.formatDuration(duration, duration >= 3600 ? Formatter.DurationLong : Formatter.DurationShort)
                    }
                }

                MenuItem {
                    visible: isPhone
                    //% "Call"
                    text: qsTrId("components_contacts-me-call")
                    onClicked: {
                        if (Telephony.voiceSimUsageMode == Telephony.AlwaysAskSim) {
                            simPicker.active = true
                        } else {
                            root.startPhoneCall(remoteUid, "")
                        }
                    }
                }
                MenuItem {
                    visible: isPhone
                    //% "Send message"
                    text: qsTrId("components_contacts-me-send_message")
                    onClicked: root.startSms(remoteUid)
                }
                MenuItem {
                    visible: !isPhone
                    // As above
                    text: qsTrId("components_contacts-me-send_message")
                    onClicked: root.startInstantMessage(localUid, remoteUid)
                }
            }
        }
    }
}
