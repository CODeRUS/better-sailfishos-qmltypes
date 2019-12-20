/*
 * Copyright (c) 2013 – 2019 Jolla Ltd.
 * Copyright (c) 2019 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Nemo.Email 0.1
import org.nemomobile.contacts 1.0
import com.jolla.email.settings.translations 1.0
import org.nemomobile.configuration 1.0

Item {
    id: messageComposer

    anchors.fill: parent

    property alias attachmentsModel: attachmentFiles
    property alias emailSubject: message.subject
    property alias emailTo: message.to
    property alias emailCc: message.cc
    property alias emailBcc: message.bcc
    property alias emailBody: message.body
    property alias messageId: message.messageId

    property alias _toSummary: to.summary
    property alias _bodyText: body.text

    property string action
    property alias originalMessageId: originalMessage.messageId
    property int accountId
    property string signature
    property bool validSignatureSet
    property bool hasRecipients: !to.empty || !cc.empty || !bcc.empty
    property Page popDestination
    property int undownloadedAttachmentsCount
    property bool _isPortrait: !pageStack.currentPage || pageStack.currentPage.isPortrait
    property bool draft // opened from draft
    property bool autoSaveDraft
    property bool popOnDraftSaved
    property bool discardUndownloadedAttachments
    property alias toFieldHasFocus: to.activeFocus
    property int totalAttachmentSize
    readonly property bool maxAttachmentSizeExceeded: totalAttachmentSize > attachmentSizeMaxConfig.value

    // avoid flashing menu when popping page
    property bool _effectiveAutoSaveDraft: autoSaveDraft
    //: Discard draft message
    //% "Discard draft"
    readonly property string _strDiscardDraft: qsTrId("jolla-components_email-me-discard_draft")
    //: Save draft message
    //% "Save draft"
    readonly property string _strSaveDraft: qsTrId("jolla-components_email-me-save_draft")
    //: Send message
    //% "Send"
    readonly property string _strSend: qsTrId("jolla-components_email-me-send")

    signal requestDraftRemoval(int messageId)

    function _ensureRecipientsComplete() {
        to.updateSummary()
        cc.updateSummary()
        bcc.updateSummary()
    }

    onSignatureChanged: {
        // Sometimes ConfigurationValue return undefined in the first read
        if (!validSignatureSet && signature) {
            loadQuotedBody()
            validSignatureSet = true
        }
    }

    // FIXME: this is not safe or good. should get info from pagestack when item gets popped.
    Component.onDestruction: {
        if (_effectiveAutoSaveDraft && messageComposer.undownloadedAttachmentsCount === 0
                && messageContentModified()) {
            saveDraft()
        }
    }

    EmailMessage {
        id: message
        onSendEnqueued: {
            messageComposer.enabled = true
            if (success) {
                _effectiveAutoSaveDraft = false
                if (popDestination) {
                    // pop any page/dialog on top of composer if it exists
                    pageStack.pop(popDestination)
                } else {
                    pageStack.pop()
                }
            }
        }
    }

    EmailMessage {
        id: originalMessage

        onQuotedBodyChanged: {
            loadQuotedBody()
        }
    }

    ListModel {
        id: attachmentFiles
    }

    AttachmentListModel {
        id: attachmentListModel
    }

    PeopleModel {
        id: contactSearchModel
    }

    Component {
        id: accountCreatorComponent
        AccountCreation {
            endDestination: pageStack.find(function(page) {
                return true
            })
        }
    }

    function _messagePriority(index) {
        return (index === 1 ? EmailMessage.HighPriority : (index === 2 ? EmailMessage.LowPriority : EmailMessage.NormalPriority))
    }

    function setOriginalMessageAttachments() {
        undownloadedAttachmentsCount = 0
        if (draft) {
            attachmentListModel.messageId = message.messageId
        } else {
            attachmentListModel.messageId = originalMessage.messageId
        }

        //Save any existent attachment that is not from the original message
        var i
        if (attachmentFiles.count) {
            for (i = attachmentFiles.count -1; i >= 0; --i) {
                if (attachmentFiles.get(i).FromOriginalMessage === "true") {
                    attachmentFiles.remove(i)
                }
            }
        }

        for (i = 0; i < attachmentListModel.count; ++i) {
            // first check whether attachment is downloaded or not.
            if (attachmentListModel.isDownloaded(i)) {
                // if attachment downloaded we should try to save it on a disk
                if (!emailAgent.downloadAttachment(originalMessage.messageId, attachmentListModel.location(i))) {
                    console.warn("Failed to save attachment " + attachmentListModel.location(i) + " on a disk:")
                }
            }
            attachmentFiles.append({"url": attachmentListModel.url(i), "title": attachmentListModel.displayName(i),
                                       "mimeType": attachmentListModel.mimeType(i), "FromOriginalMessage": "true"})

            if (attachmentListModel.url(i) === "") {
                ++undownloadedAttachmentsCount
            }
        }
    }

    function _originalMessageAttachmentsDownloaded() {
        for (var i = 0; i < attachmentFiles.count; ++i) {
            if (attachmentFiles.get(i).url === "") {
                return false
            }
        }
        return true
    }

    function removeUndownloadedAttachments() {
        //Remove any existent attachment that is not downloaded
        if (attachmentFiles.count) {
            for (var i = attachmentFiles.count -1; i >= 0; --i) {
                if (attachmentFiles.get(i).url === "") {
                    attachmentFiles.remove(i)
                }
            }
        }
        undownloadedAttachmentsCount = 0
    }

    function buildMessage() {
        message.to = to.recipientsToString()
        message.cc = cc.recipientsToString()
        message.bcc = bcc.recipientsToString()
        message.from = from.value
        message.signingPlugin = cryptoSignatureSwitch.checked
            ? accountListModel.cryptoSignatureType(accountId) : ""
        message.signingKeys = cryptoSignatureSwitch.checked
            ? accountListModel.cryptoSignatureIds(accountId) : []
        message.priority = _messagePriority(importance.currentIndex)
        message.subject = subject.text
        message.body = body.text + body.quote
        message.requestReadReceipt = requestReadReceiptSwitch.checked

        if (attachmentFiles.count > 0) {
            var att = []
            for (var i = 0; i < attachmentFiles.count; ++i) {
                att.push(attachmentFiles.get(i).url)
            }
            message.attachments = att
        }
    }

    function sendMessage() {
        // In case something goes wrong don't save invalid references
        if (!_originalMessageAttachmentsDownloaded()) {
            removeUndownloadedAttachments()
        }
        buildMessage()
        messageComposer.enabled = false
        message.send()
    }

    function saveDraft() {
        // In case something goes wrong don't save invalid references
        if (!_originalMessageAttachmentsDownloaded()) {
            removeUndownloadedAttachments()
        }
        buildMessage()
        message.saveDraft()
        if (popOnDraftSaved) {
            if (popDestination) {
                pageStack.pop(popDestination)
            } else {
                pageStack.pop()
            }
        }
    }

    function _discardDraft() {
        _effectiveAutoSaveDraft = false

        // pop any page/dialog on top of composer if it exists
        if (popDestination) {
            pageStack.pop(popDestination)
        } else {
            pageStack.pop()
        }
        if (draft) {
            // handling or ignoring depends on caller
            requestDraftRemoval(message.messageId)
        }
    }

    function isSelectedAttachment(acceptedItem) {
        for (var i = 0; i < attachmentFiles.count; ++i) {
            var attachedItem = attachmentFiles.get(i)
            if (acceptedItem.filePath === attachedItem.filePath) {
                return true
            }
        }
        return false
    }

    function modifyAttachments() {
        var obj = pageStack.animatorPush(contentPicker)
        obj.pageCompleted.connect(function(picker) {
            picker.selectedContentChanged.connect(function() {
                for (var i = 0; i < picker.selectedContent.count; ++i) {
                    var acceptedItem = picker.selectedContent.get(i)
                    if (!isSelectedAttachment(acceptedItem)) {
                        attachmentFiles.insert(0, acceptedItem)
                    }
                }
            })
        })
    }

    function showAttachments() {
        var properties = { attachmentFiles: attachmentFiles }
        var obj = pageStack.animatorPush(Qt.resolvedUrl('AttachmentsPage.qml'), properties)
        obj.pageCompleted.connect(function(page) {
            page.addAttachments.connect(modifyAttachments)
        })
    }

    function messageContentModified() {
        if (hasRecipients || subject.text != '' || body.text != ''
                && body.text != signature  || attachmentFiles.count) {
            return true
        } else {
            return false
        }
    }

    function forwardContentAvailable() {
        if (!_originalMessageAttachmentsDownloaded()) {
            pageStack.animatorPush(Qt.resolvedUrl('AttachmentDownloadPage.qml'), {email: originalMessage,
                                       composerItem: messageComposer, undownloadedAttachmentsCount: undownloadedAttachmentsCount})
        }
    }

    function forwardPrecursor() {
        var precursor = '\n\n'
        //: Indicator of original message content
        //% "--- Original message ---"
        precursor += qsTrId("jolla-components_email-la-original_message")
        return precursor
    }

    function replyPrecursor() {
        var precursor = '\n\n'
        var timestamp = Format.formatDate(originalMessage.date, Formatter.DateFull)

        //: Indicator of reply message origin (%1:timestamp %2:mailSender)
        //% "On %1, %2 wrote:"
        precursor += qsTrId("jolla-components_email-la-reply_message_origin").arg(timestamp).arg(originalMessage.fromDisplayName)
        return precursor
    }

    function loadQuotedBody() {
        if (action && action != 'forward') {
            body.text = replyPrecursor()
            body.quote = originalMessage.quotedBody + signature
            // Append max 10000 chars from the quote
            body.appendQuote(10000)
        }
    }

    SilicaFlickable {
        property bool waitToAppend
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: accountListModel.numberOfAccounts ? contentItem.y + contentItem.height : viewPlaceHolder.height

        NoAccountsPlaceholder {
            id: viewPlaceHolder
            enabled: !accountListModel.numberOfAccounts
        }

        onAtYEndChanged: {
            if (atYEnd && body.quote.length) {
                if (quickScrollAnimating) {
                    waitToAppend = true
                } else {
                    // Append next max 2500 chars from the quote
                    body.appendQuote(2500)
                }
            }
        }

        onQuickScrollAnimatingChanged: {
            if (!quickScrollAnimating && waitToAppend) {
                waitToAppend = false
                // Append next max 2500 chars from the quote
                body.appendQuote(2500)
            }
        }

        RemorsePopup {
            id: discardDraftRemorse
        }

        PullDownMenu {
            onActiveChanged: {
                if (active) {
                    _ensureRecipientsComplete()
                }
            }

            MenuItem {
                visible: accountListModel.numberOfAccounts
                // explicit save action only when not doing it automatically
                text: autoSaveDraft ? _strDiscardDraft : _strSaveDraft
                enabled: messageContentModified()
                //% "Discarding draft"
                onClicked: autoSaveDraft ? (draft ? _discardDraft()
                                                  : discardDraftRemorse.execute(qsTrId("email-me-discarding_draft"), _discardDraft))
                                         : saveDraft()
            }
            MenuItem {
                visible: accountListModel.numberOfAccounts
                text: _strSend
                enabled: hasRecipients && (subject.text != '' || body.text != '') && !maxAttachmentSizeExceeded
                onClicked: sendMessage()
            }
            MenuItem {
                visible: !accountListModel.numberOfAccounts
                //: Add account menu item
                //% "Add account"
                text: qsTrId("jolla-email-me-add_account")
                onClicked: {
                    var accountCreator = accountCreatorComponent.createObject(messageComposer)
                    accountCreator.creationCompleted.connect(function() { accountCreator.destroy() })
                }
            }
        }

        PushUpMenu {
            visible: accountListModel.numberOfAccounts && flickable.contentHeight > 1.5*(isLandscape ? Screen.width : Screen.height)

            onActiveChanged: {
                if (active) {
                    _ensureRecipientsComplete()
                }
            }

            MenuItem {
                text: _strSend
                enabled: hasRecipients && (subject.text != '' || body.text != '')
                onClicked: sendMessage()
            }
            MenuItem {
                text: autoSaveDraft ? _strDiscardDraft : _strSaveDraft
                enabled: messageContentModified()
                //% "Discarding draft"
                onClicked: autoSaveDraft ? (draft ? _discardDraft()
                                                  : discardDraftRemorse.execute(qsTrId("email-me-discarding_draft"), _discardDraft))
                                         : saveDraft()
            }
        }


        Column {
            id: contentItem
            visible: accountListModel.numberOfAccounts
            y: isLandscape ? Theme.paddingMedium : 0
            width: parent.width - x
            opacity: messageComposer.enabled ? 1. : Theme.opacityLow

            PageHeader {
                id: pageHeader
                //: New mail page title
                //% "New mail"
                title: qsTrId("jolla-email-he-new_mail")
            }

            Compressor {
                id: metadata
                expanderItem: expanderControl

                width: parent.width

                Column {
                    width: parent.width

                    EmailRecipientField {
                        id: to

                        compressible: false
                        contactSearchModel: contactSearchModel
                        showLabel: _isPortrait

                        //: 'To' recipient label
                        //% "To"
                        placeholderText: qsTrId("jolla-components_email-la-to")

                        onLastFieldExited: {
                            if (!cc.compressed) {
                                cc.forceActiveFocus()
                            } else if (!bcc.compressed) {
                                bcc.forceActiveFocus()
                            } else {
                                subject.forceActiveFocus()
                            }
                        }
                    }
                    EmailRecipientField {
                        id: cc

                        contactSearchModel: contactSearchModel
                        showLabel: _isPortrait

                        //: 'CC' recipient label
                        //% "Cc"
                        placeholderText: qsTrId("jolla-components_email-la-cc")

                        onLastFieldExited: {
                            if (!bcc.compressed) {
                                bcc.forceActiveFocus()
                            } else {
                                subject.forceActiveFocus()
                            }
                        }
                    }
                    EmailRecipientField {
                        id: bcc

                        contactSearchModel: contactSearchModel
                        showLabel: _isPortrait

                        //: 'BCC' recipient label
                        //% "Bcc"
                        placeholderText: qsTrId("jolla-components_email-la-bcc")

                        onLastFieldExited: {
                            subject.forceActiveFocus()
                        }
                    }
                    MetaDataComboBox {
                        id: from
                        // Don't allow to change from account of a existent draft
                        visible: !draft && accountListModel.numberOfAccounts > 1

                        menu: ContextMenu {
                            width: parent ? parent.width : 0

                            Repeater {
                                id: fromRepeater
                                model: accountListModel
                                MenuItem {
                                    text: emailAddress
                                }
                            }
                        }

                        //: From label
                        //% "From:"
                        label: qsTrId("jolla-components_email-la-from")

                        onCurrentIndexChanged: {
                            if (accountId !== accountListModel.accountId(currentIndex)) {
                                accountId = accountListModel.accountId(currentIndex)
                                var newSignature = '\n\n-- \n' + accountListModel.signature(accountId)
                                if (newSignature !== signature) {
                                    // only part of the signature is in the screen, flush the rest
                                    if (body.quote.length && body.quote.length <= signature.length) {
                                        body.appendQuote(body.quote.length)
                                    }

                                    var appendSignature = accountListModel.appendSignature(accountId)
                                    var textAfterSignature = ""
                                    var tempText = ""
                                    if (body.quote.length) {
                                        tempText = body.quote
                                    } else {
                                        tempText = body.text
                                    }

                                    var signatureIndex = tempText.lastIndexOf(signature)
                                    if (signatureIndex != -1) {
                                        textAfterSignature = tempText.substring(signatureIndex + signature.length, tempText.length)
                                        tempText = tempText.substring(0, signatureIndex)
                                    }

                                    if (appendSignature) {
                                        signature = newSignature
                                    } else {
                                        signature = ""
                                    }

                                    if (body.quote.length) {
                                        body.quote = tempText + signature + textAfterSignature
                                    } else {
                                        body.text = tempText + signature + textAfterSignature
                                    }
                                }
                            }
                        }
                    }
                    MetaDataComboBox {
                        id: importance
                        compressible: currentIndex === 0

                        menu: ContextMenu {
                            width: parent ? parent.width : 0

                            MenuItem {
                                //: Normal priority
                                //% "Normal"
                                text: qsTrId("jolla-email-la-priority_Normal")
                            }
                            MenuItem {
                                //: High priority
                                //% "High"
                                text: qsTrId("jolla-email-la-priority_high")
                            }
                            MenuItem {
                                //: Low priority
                                //% "Low"
                                text: qsTrId("jolla-email-la-priority_low")
                            }
                        }

                        //: Importance label
                        //% "Importance:"
                        label: qsTrId("jolla-components_email-la-importance")
                    }
                    CompressibleItem {
                        id: cryptoSignatureSwitch
                        property alias checked: signatureSwitch.checked
                        visible: accountListModel.cryptoSignatureType(accountId).length > 0
                        compressible: !signatureSwitch.error
                        SignatureSwitch {
                            id: signatureSwitch
                            visible: !cryptoSignatureSwitch.compressed
                            width: parent.width
                            checked: accountListModel.useCryptoSignatureByDefault(accountId)
                            protocol: message.cryptoProtocolForKey
                                        (accountListModel.cryptoSignatureType(accountId)
                                        ,accountListModel.cryptoSignatureIds(accountId))
                            error: message.signatureStatus == EmailMessage.SignedInvalid
                        }
                    }
                    CompressibleItem {
                        id: requestReadReceiptItem
                        compressible: true
                        TextSwitch {
                            id: requestReadReceiptSwitch
                            checked: false
                            visible: !requestReadReceiptItem.compressed
                            //: Enables read receipt request
                            //% "Request read receipt"
                            text: qsTrId("jolla-email-la-request_read_receipt")
                        }
                    }
                    CompressibleItem {
                        id: attachmentsItem

                        compressible: attachmentFiles.count === 0

                        Item {
                            width: parent.width
                            // Padding small between this and subject field
                            implicitHeight: attachmentBg.height + (attachmentSizeLabel.visible && attachmentSizeLabel.text.length ? attachmentSizeLabel.height : 0) + Theme.paddingSmall

                            ListItem {
                                id: attachmentBg
                                onClicked: attachmentFiles.count === 0 ? modifyAttachments() : showAttachments()
                                enabled: !attachmentsItem.compressed
                                // If there is nothing to remove, don't show menu.
                                menu: attachmentFiles.count > 0 ? contextMenuComponent : null

                                // TODO: Should be changed to Label, default color should be primaryColor
                                // as this is something that can be pressed. Need to change _updateAttachmentText as well.
                                TextField {
                                    id: attachments

                                    anchors {
                                        left: parent.left
                                        right: addButton.left
                                        rightMargin: Theme.paddingMedium
                                        verticalCenter: parent.verticalCenter
                                        verticalCenterOffset: Theme.paddingSmall
                                    }
                                    labelVisible: false
                                    color: attachmentBg.highlighted ? Theme.highlightColor : Theme.primaryColor
                                    placeholderColor: color

                                    readOnly: true
                                    // Disable mouse handling so that List
                                    enabled: false

                                    //: Attachments selector
                                    //% "Add attachment"
                                    placeholderText: qsTrId("jolla-components_email-ph-attachments")
                                }

                                Image {
                                    id: addButton

                                    source: "image://theme/icon-m-add" + (attachmentBg.highlighted ? "?" + Theme.highlightColor : "")
                                    opacity: Theme.opacityHigh

                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        right: parent.right
                                        rightMargin: Theme.horizontalPageMargin - Theme.paddingMedium
                                    }
                                }
                            }

                            Label {
                                id: attachmentSizeLabel

                                anchors {
                                    top: attachmentBg.bottom
                                    left: attachmentBg.left
                                    leftMargin: Theme.horizontalPageMargin
                                    right: attachmentBg.right
                                    rightMargin: Theme.horizontalPageMargin
                                }

                                color: maxAttachmentSizeExceeded ? "#ff4d4d" : Theme.highlightColor
                                wrapMode: Text.Wrap
                                width: attachmentBg.width
                                font.pixelSize: Theme.fontSizeExtraSmall

                                text: {
                                    if (totalAttachmentSize > 0) {
                                        if (maxAttachmentSizeExceeded) {
                                            //% "Email cannot be sent! Total file size exceeds %1."
                                            return qsTrId("jolla-components_email-la-attachments_size_exceed_max").arg(Format.formatFileSize(attachmentSizeMaxConfig.value))
                                        } else if (totalAttachmentSize > attachmentSizeWarningConfig.value) {
                                            //% "Total file size exceeds %1. Consider removing some attachments."
                                            return qsTrId("jolla-components_email-la-attachments_size_exceed_warning").arg(Format.formatFileSize(attachmentSizeWarningConfig.value))
                                        }
                                    }
                                    return ""
                                }
                            }

                            // This should be attachments.text: _updateAttachmentText() instead
                            // but currectly _updateAttachmentText() break the binding.
                            Connections {
                                target: attachmentFiles
                                onCountChanged: _updateAttachmentText()
                            }

                            Component {
                                id: contextMenuComponent

                                ContextMenu {
                                    MenuItem {
                                        visible: attachmentFiles.count > 0
                                        //: When plural "Remove all attachments" and singular "Remove attachment".
                                        //% "Remove attachment"
                                        text: qsTrId("jolla-email-me-remove_all_attachments", attachmentFiles.count)
                                        onClicked: {
                                            attachmentFiles.clear()
                                            attachments.text = ""
                                        }
                                    }
                                }
                            }
                        }
                    }
                    MetaDataTextField {
                        id: subject
                        compressible: false

                        //: Subject label
                        //% "Subject"
                        placeholderText: qsTrId("jolla-components_email-la-subject")
                        onEnterKeyClicked: {
                            body.forceActiveFocus()
                        }
                    }
                }
            }

            MouseArea {
                width: parent.width
                height: expanderControl.height
                Expander {
                    id: expanderControl

                    minimumHeight: metadata.minimumHeight
                    maximumHeight: metadata.maximumHeight

                    anchors {
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin - Theme.paddingMedium
                    }
                }
                onClicked: body.forceActiveFocus()
            }

            // What should this control be?  For now, just a text field
            TextArea {
                id: body

                property string quote

                width: parent.width
                background: null // expanding text areas with nothing below them don't need bottom border background
                height: Math.max(messageComposer.height - (contentItem.y + (isLandscape ? 0 : pageHeader.height)
                                                           + metadata.height + expanderControl.height),
                                 implicitHeight)
                color: Theme.primaryColor
                font { pixelSize: Theme.fontSizeMedium; family: Theme.fontFamily }

                //% "Write message..."
                placeholderText: (action.slice(0, 5) !== 'reply') ? qsTrId("jolla-components_email-ph-body")
                                                                    //: Reply text placeholder
                                                                    //% "Write reply..."
                                                                  : qsTrId("jolla-components_email-ph-reply")

                function appendQuote(maxLength) {
                    var lineBreak = -1
                    if (quote.length > maxLength) {
                        lineBreak = quote.lastIndexOf('\n', maxLength)
                    }
                    var cutIndex = (lineBreak < maxLength - 200) ? maxLength : lineBreak
                    text = text + quote.substring(0, cutIndex)
                    quote = quote.substring(cutIndex)
                }
            }
        }
        VerticalScrollDecorator {}
    }

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: !messageComposer.enabled
    }

    Component {
        id: contentPicker

        MultiContentPickerDialog {
            //% "Attach files"
            title: qsTrId("jolla-components_email-he-attach-files")
        }
    }

    EmailAccountListModel {
        id: accountListModel
        onlyTransmitAccounts: true
    }

    function _updateAttachmentText() {
        var names = []
        var attachmentTextUpdated = false
        totalAttachmentSize = 0
        for (var i = 0; i < attachmentFiles.count; ++i) {
            var attachmentObj = attachmentFiles.get(i)
            names.push(attachmentObj.title)
            totalAttachmentSize += attachmentObj.fileSize
            attachments.text = names.join(", ")
            if (!attachmentTextUpdated && attachments.implicitWidth > attachments.width) {
                while (names.length > 1 && attachments.implicitWidth > attachments.width) {
                    names.pop()
                    //: Number of additional attachments that are not currently shown
                    //% "%n other(s)"
                    var more = qsTrId("jolla-components_email-la-attchements_summary", attachmentFiles.count - names.length)
                    attachments.text = names.join(", ") + ", " + more
                }
                attachmentTextUpdated = true
            }
        }

        var attachmentSizeText = totalAttachmentSize == 0 ? "" : " (" + Format.formatFileSize(totalAttachmentSize) + ")"
        attachments.text += attachmentSizeText

        // This format is used in case above loop produces too long format.
        if (attachments.implicitWidth > attachments.width) {
            //: Number of attachments, should have singular and plurar formats. Text should be relatively short (max 24 chars).
            //% "%n attachment(s)"
            attachments.text = qsTrId("jolla-components_email-la-attchements", attachmentFiles.count) + attachmentSizeText
        }

        attachments.text = attachmentFiles.count > 0 ? attachments.text : ""
    }

    Component.onCompleted: {
        if (accountListModel.numberOfAccounts) {
            if (action) {
                accountId = originalMessage.accountId
            }
            if (draft) {
                accountId = message.accountId
            }

            // If account is not set or is not sending capable, use the default one if it exists
            if (!accountId || accountListModel.indexFromAccountId(accountId) < 0) {
                accountId = defaultAccountConfig.value
            }

            var currentIndex = 0

            if (accountId) {
                currentIndex = accountListModel.indexFromAccountId(accountId)
                if (currentIndex >= 0) {
                    from.currentIndex = currentIndex
                } else {
                    // Use first account in the model
                    accountId = accountListModel.accountId(0)
                }
            } else {
                // If accountId is not valid(e.g default account got disabled) use first account in the model
                accountId = accountListModel.accountId(0)
            }

            if (accountListModel.appendSignature(accountId)) {
                signature = '\n\n-- \n' + accountListModel.signature(accountId)
            }

            var priority = EmailMessage.NormalPriority

            if (action) {
                message.originalMessageId = originalMessage.messageId
                var subjectText = originalMessage.subject
                if (action == 'forward') {
                    // Not translated:
                    if (subjectText.slice(0, 4) != 'Fwd:') {
                        subjectText = 'Fwd: ' + subjectText
                    }
                    priority = originalMessage.priority
                    message.responseType = EmailMessage.Forward
                    if (!originalMessage.calendarInvitationSupportsEmailResponses) {
                        // Do not attach original attachments, since SmartForward will be used by EAS daemon
                        // and server will attach them automatically. This is valid only for EAS accounts.
                        // TODO: Update it with a different check if/when calendarInvitationSupportsEmailResponses
                        // will returns true for non-EAS accounts as well.
                        // TODO:2 User will not/shouldn't be able to remove original invitation attachments.
                        setOriginalMessageAttachments()
                    }

                    if (originalMessage.contentType == EmailMessage.Plain) {
                        // to be removed, just temporary to provide at least same functionality as before
                        body.text = forwardPrecursor()
                        body.quote = originalMessage.quotedBody + signature
                        // Append max 10000 chars from the quote
                        body.appendQuote(10000)
                    } else { // originalMessage.contentType == EmailMessage.HTML
                        // forward as an attachment
                        attachmentFiles.append({
                            "url": "id://" + originalMessageId,
                            "fileSize": originalMessage.size,
                            "title": originalMessage.subject,
                            "mimeType": "message/rfc822",
                            "FromOriginalMessage": "false"
                        })
                        body.text = message.body + signature
                    }
                } else {
                    // Not translated:
                    if (subjectText.slice(0, 3) != 'Re:') {
                        subjectText = 'Re: ' + subjectText
                    }
                    var replyTo = originalMessage.replyTo ? originalMessage.replyTo : originalMessage.fromAddress

                    // Use slice() to create a new array object that can be modified (QML limitation, should implicitly happen when you start to modify array var)
                    var recipients = originalMessage.recipients.slice()
                    var recipientsUsed = false

                    // don't reply to yourself when choosing reply for message you sent
                    var usersEmailAddress = accountListModel.emailAddressFromAccountId(messageComposer.accountId)
                    if ((action == 'reply' || action == 'replyAll') && usersEmailAddress == replyTo && recipients.length > 0) {
                        replyTo = recipients
                        recipientsUsed = true
                    }

                    to.setRecipients(replyTo)
                    if (action == 'replyAll') {
                        message.responseType = EmailMessage.ReplyToAll

                        if (!recipientsUsed) {
                            var fromIndex = recipients.indexOf(accountListModel.emailAddress(currentIndex >= 0 ? currentIndex : 0))
                            if (fromIndex != -1) {
                                // Remove current from address from the list
                                recipients.splice(fromIndex, 1)
                            }
                            var replyToIndex = recipients.indexOf(replyTo)
                            if (replyToIndex != -1) {
                                // Remove to address from the list
                                recipients.splice(replyToIndex, 1)
                            }

                            cc.setRecipients(recipients)
                        }
                    } else {
                        message.responseType = EmailMessage.Reply
                    }
                }

                subject.text = subjectText
            } else {
                // Don't overwrite response type of existent draft
                if (!draft) {
                    message.responseType = EmailMessage.NoResponse
                }
                priority = message.priority
                to.setRecipients(message.to)
                cc.setRecipients(message.cc)
                bcc.setRecipients(message.bcc)
                subject.text = message.subject
                body.text = message.body + (draft ? "" : signature)
                if (draft) {
                    setOriginalMessageAttachments()
                }
            }

            importance.currentIndex = (priority === EmailMessage.HighPriority) ? 1 : (priority === EmailMessage.LowPriority) ? 2 : 0

            // Do not change request read receipt value of existent draft
            if (!draft) {
                requestReadReceiptSwitch.checked = false
            } else {
                requestReadReceiptSwitch.checked = message.requestReadReceipt
            }

            if (to.empty && cc.empty && bcc.empty) {
                to.forceActiveFocus()
            } else {
                if (subject.text == "") {
                    subject.forceActiveFocus()
                } else {
                    body.forceActiveFocus()
                    if (!action) {
                        // Move the cursor to the end of the body, except with reply/fw
                        body.cursorPosition = body.text.length - signature.length
                    }
                }
            }
        }
    }

    ConfigurationValue {
        id: defaultAccountConfig
        key: "/apps/jolla-email/settings/default_account"
        defaultValue: 0
    }

    ConfigurationValue {
        id: attachmentSizeWarningConfig
        key: "/apps/jolla-email/settings/attachment_size_warning"
        defaultValue: 10 * 1024 * 1024  // 10 MB
    }

    ConfigurationValue {
        id: attachmentSizeMaxConfig
        key: "/apps/jolla-email/settings/attachment_size_max"
        defaultValue: 25 * 1024 * 1024  // 25 MB
    }
}
