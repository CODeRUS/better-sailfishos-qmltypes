import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import Sailfish.Telephony 1.0
import org.nemomobile.contacts 1.0
import org.nemomobile.commhistory 1.0

ListItem {
    id: root

    property SimManager simManager
    property bool hidePhoneActions
    property var modelFactory
    property var contact
    property real leftMargin: Theme.paddingMedium + Theme.iconSizeMedium + Theme.paddingMedium
    property bool showYear

    readonly property bool isPhone: model.localUid.indexOf('/ring/tel/') >= 0
    readonly property bool isMessage: model.eventType !== CommCallModel.CallEvent && model.eventType !== CommCallModel.VoicemailEvent
    readonly property int modemIndex: simManager.indexOfModemFromImsi(model.subscriberIdentity)

    signal startPhoneCall(string modemPath)
    signal startSms()
    signal startInstantMessage()


    //--- internal properties follow

    contentHeight: !visible
                   ? 0
                   : timestampSecondaryLabel.y + timestampSecondaryLabel.height + Theme.paddingMedium

    menu: (!isPhone || !hidePhoneActions) ? contextMenuComponent : null

    onClicked: openMenu()

    HighlightImage {
        id: icon

        anchors {
            top: root.isMessage ? parent.top : undefined
            topMargin: Theme.paddingMedium + Theme.paddingSmall/2
            verticalCenter: root.isMessage ? undefined : titleLabel.verticalCenter
            left: parent.left
            leftMargin: root.leftMargin/2 - width/2
        }

        highlighted: root.highlighted
        source: {
            if (root.isMessage) {
                return "image://theme/icon-m-activity-messaging"
            } else if (model.eventType === CommCallModel.VoicemailEvent) {
                return "image://theme/icon-m-voicemail"
            } else {
                if (model.direction === CommCallModel.Inbound) {
                    return model.isMissedCall
                        ? "image://theme/icon-s-activity-missed-call"
                        : "image://theme/icon-s-activity-incoming-call"
                } else {
                    return "image://theme/icon-s-activity-outgoing-call"
                }
            }
        }
    }

    Label {
        id: timestampLabel

        anchors {
            bottom: timestampSecondaryLabel.top
            right: timestampSecondaryLabel.right
        }

        text: Format.formatDate(model.endTime, Format.TimeValue)
        font.pixelSize: Theme.fontSizeExtraSmall
        color: root.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        truncationMode: TruncationMode.Fade
    }

    Label {
        id: timestampSecondaryLabel

        anchors {
            verticalCenter: durationIcon.visible || simIndicator.visible
                            ? durationIcon.verticalCenter
                            : metadataLabel.verticalCenter
            right: parent.right
            rightMargin: Theme.paddingLarge
        }

        text: Format.formatDate(model.endTime, root.showYear ? Format.DateMedium : Format.DateMediumWithoutYear)
        font.pixelSize: Theme.fontSizeExtraSmall
        color: root.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        truncationMode: TruncationMode.Fade
    }

    Label {
        id: titleLabel

        anchors {
            top: parent.top
            topMargin: Theme.paddingMedium
            left: parent.left
            leftMargin: root.leftMargin
            right: timestampLabel.right
        }

        text: {
            if (root.isMessage) {
                var messageText
                if (freeText) {
                    messageText = freeText
                } else if (subject) {
                    messageText = subject
                } else if (model.eventType == CommHistory.MMSEvent) {
                    //% "Multimedia message"
                    messageText = qsTrId("components_contacts-la-multimedia_message")
                } else {
                    //% "Message"
                    messageText = qsTrId("components_contacts-la-message")
                }
                return messageText
            } else {
                return model.remoteUid
            }
        }

        font.pixelSize: Theme.fontSizeMedium
        color: root.highlighted ? Theme.highlightColor: Theme.primaryColor
        textFormat: Text.PlainText
        truncationMode: Text.ElideRight
        wrapMode: Text.Wrap
        maximumLineCount: 2
    }

    Label {
        id: endpointLabel

        x: root.leftMargin
        y: titleLabel.y + titleLabel.height
        width: Math.min(implicitWidth, parent.width - x - timestampLabel.width)

        visible: root.isMessage
        text: model.remoteUid
        font.pixelSize: Theme.fontSizeExtraSmall
        color: root.highlighted ? Theme.secondaryHighlightColor: Theme.secondaryColor
        truncationMode: TruncationMode.Fade
    }

    ContactActivitySimIndicator {
        id: simIndicator

        anchors {
            left: durationLabel.visible ? durationLabel.right : titleLabel.left
            leftMargin: durationLabel.visible ? Theme.paddingSmall : Math.round(-Theme.paddingSmall/2)
            verticalCenter: durationLabel.verticalCenter
        }

        simManager: root.simManager
        imsi: model.subscriberIdentity

    }

    Label {
        id: metadataLabel

        anchors {
            top: endpointLabel.visible ? endpointLabel.bottom : titleLabel.bottom
            left: titleLabel.left
        }

        text: modelFactory.getDetailMetadataForRemoteUid(root.contact, model.remoteUid)
        font.pixelSize: Theme.fontSizeExtraSmall
        color: root.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        truncationMode: TruncationMode.Fade
    }

    HighlightImage {
        id: durationIcon
        visible: !root.isMessage

        anchors {
            top: metadataLabel.bottom
            left: titleLabel.left
            leftMargin: Math.round(-Theme.paddingSmall/2)
        }

        highlighted: root.highlighted
        source: "image://theme/icon-s-duration"
    }

    Label {
        id: durationLabel
        visible: durationIcon.visible

        anchors {
            verticalCenter: durationIcon.verticalCenter
            left: durationIcon.right
            leftMargin: Theme.paddingSmall
        }

        property int duration: (model.endTime.valueOf() - model.startTime.valueOf()) / 1000
        text: Format.formatDuration(duration, duration >= 3600 ? Formatter.DurationLong : Formatter.DurationShort)
        font.pixelSize: Theme.fontSizeExtraSmall
        color: root.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        truncationMode: TruncationMode.Fade
    }

    property Component contextMenuComponent: Component {
        ContextMenu {
            id: contextMenu

            SimPickerMenuItem {
                id: simPicker
                menu: contextMenu
                onTriggerAction: root.startPhoneCall(modemPath)
            }

            Item {
                width: 1
                height: Theme.paddingSmall
            }

            MenuItem {
                visible: root.isPhone
                //% "Call"
                text: qsTrId("components_contacts-me-call")
                onClicked: {
                    if (Telephony.voiceSimUsageMode == Telephony.AlwaysAskSim) {
                        simPicker.active = true
                    } else {
                        root.startPhoneCall("")
                    }
                }
            }

            MenuItem {
                //% "Send message"
                text: qsTrId("components_contacts-me-send_message")
                onClicked: {
                    if (root.isPhone) {
                        root.startSms()
                    } else {
                        root.startInstantMessage()
                    }
                }
            }
        }
    }
}
