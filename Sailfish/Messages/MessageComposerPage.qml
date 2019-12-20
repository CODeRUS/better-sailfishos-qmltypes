import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Messages 1.0
import Sailfish.Contacts 1.0
import Sailfish.Telephony 1.0
import org.nemomobile.contacts 1.0
import org.nemomobile.commhistory 1.0

Page {
    id: root

    property string validatedLocalUid
    property var validatedRemoteUids: []
    property alias recipientField: recipientField
    property alias errorLabel: errorLabel

    property alias topContent: recipientHeader.data
    property alias inputContent: inputContentRow.data

    signal recipientSelectionChanged()
    signal focusTextInput()

    _clickablePageIndicators: !(isLandscape && recipientField.activeFocus)

    onStatusChanged: {
        if (status === PageStatus.Active) {
            recipientField.forceActiveFocus()
        }
    }

    function _invalidate(errorText) {
        validatedLocalUid = ""
        validatedRemoteUids = []
        errorLabel.customErrorText = errorText || ""
    }

    function validateRecipients() {
        if (recipientField.selectedContacts.count === 0) {
            _invalidate()
            return
        }

        var localUid = ""
        var remoteUids = [ ]

        for (var i = 0; i < recipientField.selectedContacts.count; i++) {
            var contact = recipientField.selectedContacts.get(i)
            var local
            var remote = undefined

            if (contact.propertyType.length === 0 || contact.property === undefined || contact.property === {}) {
                continue
            }

            if (contact.person && contact.propertyType === "accountUri") {
                local = contact.property.path
                remote = contact.property.uri
            } else if (contact.propertyType === "phoneNumber") {
                if (MessageUtils.hasModem) {
                    // Pre-validate the number; telepathy-ring has an even stricter validation for message numbers than this
                    var normalizedNumber = Person.normalizePhoneNumber(contact.property.number)
                    if (normalizedNumber) {
                        local = MessageUtils.telepathyAccounts.ringAccountPath
                        remote = normalizedNumber
                    } else {
                        console.log("Cannot send to invalid phone number:", contact.property.number)
                        //: Invalid recipient error with details
                        //% "Invalid recipient: %1"
                        _invalidate(qsTrId("messages-la-invalid_recipient_details").arg(contact.property.number))
                        return
                    }
                } else {
                    // AccountErrorLabel will show 'no sim' error
                    _invalidate()
                    return
                }
            } else {
                console.log("Cannot create conversation with property type:", contact.propertyType, "for", contact.displayLabel)
                continue
            }

            if (localUid.length > 0 && local !== localUid) {
                console.log("Cannot create conversation with multiple local accounts! Found both '" + local + "' and '" + localUid)
                //% "Cannot send message, multiple local accounts found"
                _invalidate(qsTrId("messages-la_error_multiple_local_accounts"))
                return
            }

            localUid = local
            if (remote !== undefined) remoteUids.push(remote)
        }

        if (remoteUids.length == 0) {
            _invalidate()
            return
        }

        if (remoteUids.length === 1 && localUid === "") {
            console.log("Cannot create conversations for unsupported IM contact")
            //% "Cannot find instant messaging account"
            _invalidate(qsTrId("messages-la_error_im_account"))
            return
        }

        if (remoteUids.length > 1 && localUid != MessageUtils.telepathyAccounts.ringAccountPath) {
            console.log("Cannot create group conversations with IM accounts")
            //% "Cannot use group conversations with instant messaging"
            _invalidate(qsTrId("messages-la_error_im_account_group_conversation"))
            return
        }

        validatedLocalUid = localUid
        validatedRemoteUids = remoteUids
        errorLabel.customErrorText = ""
    }

    SilicaFlickable {
        id: messages

        anchors.fill: parent
        contentHeight: Math.max(height, recipientHeader.y + recipientHeader.height + inputContentRow.height)
        focus: true

        Column {
            id: recipientHeader

            y: root.isLandscape ? Theme.paddingMedium : 0
            width: messages.width

            PageHeader {
                //% "New message"
                title: qsTrId("jolla-messages-la-new_message")
                visible: root.isPortrait
            }

            RecipientField {
                id: recipientField

                actionType: Telephony.Message
                width: parent.width
                recentContactsCategoryMask: CommHistory.VoicecallCategory | CommHistory.VoicemailCategory
                contactSearchModel: PeopleModel { filterType: PeopleModel.FilterNone }
                showLabel: root.isPortrait

                //: A single recipient
                //% "recipient"
                placeholderText: qsTrId("jolla-messages-ph-recipient")

                //: Summary of all selected recipients, e.g. "Bob, Jane, 75553243"
                //% "Recipients"
                summaryPlaceholderText: qsTrId("jolla-messages-ph-recipients")

                onEmptyChanged: if (empty) errorLabel.customErrorText = ""
                onSelectionChanged: recipientSelectionChanged()
                onHasFocusChanged: if (!hasFocus) focusTextInput()
            }

            AccountErrorLabel {
                id: errorLabel

                visible: !recipientField.hasFocus
                padding: Theme.paddingLarge

                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }

                localUid: root.validatedLocalUid
            }
        }

        Row {
            id: inputContentRow

            y: messages.contentHeight - height
            width: parent.width
        }
    }
}
