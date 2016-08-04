/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Valerio Valerio <valerio.valerio@jolla.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import org.nemomobile.email 0.1
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

    property bool isEmailApp
    property string action
    property alias originalMessageId: originalMessage.messageId
    property int accountId
    property string signature
    property bool validSignatureSet
    property bool hasRecipients: !to.empty || !cc.empty || !bcc.empty
    property Page popDestination
    property int undownloadedAttachmentsCount
    property bool _isPortrait: !pageStack.currentPage || pageStack.currentPage.isPortrait
    property bool draft
    property bool discardDraft: true
    property bool discardUndownloadedAttachments
    property alias toFieldHasFocus: to.activeFocus

    //: Discard draft message
    //% "Discard draft"
    readonly property string _strDiscardDraft: qsTrId("jolla-components_email-me-discard_draft")
    //: Save draft message
    //% "Save draft"
    readonly property string _strSaveDraft: qsTrId("jolla-components_email-me-save_draft")
    //: Add attachment
    //% "Add attachment"
    readonly property string _strAddAttach: qsTrId("jolla-components_email-me-add_attachment")
    //: Send message
    //% "Send"
    readonly property string _strSend: qsTrId("jolla-components_email-me-send")

    signal requestDraftRemoval(int messageId)

    onSignatureChanged: {
        // Sometimes ConfigurationValue return undefined in the first read
        if (!validSignatureSet && signature) {
            loadQuotedBody()
            validSignatureSet = true
        }
    }

    Component.onDestruction: {
        if (!discardDraft && messageComposer.undownloadedAttachmentsCount === 0
                && messageContentModified()) {
            saveDraft()
        }
    }

    EmailMessage {
        id: message
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
        if(attachmentFiles.count) {
            for (var i = attachmentFiles.count -1; i >= 0; --i) {
                if (attachmentFiles.get(i).FromOriginalMessage === "true") {
                    attachmentFiles.remove(i)
                }
            }
        }

        for (var i = 0; i < attachmentListModel.count; ++i) {
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
        if(attachmentFiles.count) {
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
        message.priority = _messagePriority(importance.currentIndex)
        message.subject = subject.text
        message.body = body.text + body.quote

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
        message.send()
        discardDraft = true
        if(isEmailApp) {
            // pop any page/dialog on top of composer if it exists
            pageStack.pop(popDestination)
        } else {
            pageStack.pop()
        }
    }

    function saveDraft() {
        // In case something goes wrong don't save invalid references
        if (!_originalMessageAttachmentsDownloaded()) {
            removeUndownloadedAttachments()
        }
        buildMessage()
        message.saveDraft()

        if (!isEmailApp) {
            pageStack.pop()
        }
    }

    function _discardDraft() {
        discardDraft = true
        if(isEmailApp) {
            // pop any page/dialog on top of composer if it exists
            pageStack.pop(popDestination)
            if (draft) {
                requestDraftRemoval(message.messageId)
            }
        } else {
            pageStack.pop()
        }
    }

    function modifyAttachments() {
        var picker = pageStack.push(contentPicker, { selectedContent: attachmentFiles })
        picker.selectedContentChanged.connect(function() {
            attachmentFiles.clear()
            for(var i=0; i < picker.selectedContent.count; ++i) {
                attachmentFiles.append(picker.selectedContent.get(i))
            }
        })
    }

    function showAttachments() {
        var properties = { attachmentFiles: attachmentFiles, contentPicker: contentPicker }
        pageStack.push(Qt.resolvedUrl('AttachmentsPage.qml'), properties)
    }

    function messageContentModified() {
        if(hasRecipients || subject.text != '' || body.text != ''
                && body.text != signature  || attachmentFiles.count) {
            return true
        }
        else {
            return false
        }
    }

    function forwardContentAvailable() {
        if (!_originalMessageAttachmentsDownloaded()) {
            pageStack.push(Qt.resolvedUrl('AttachmentDownloadPage.qml'), {email: originalMessage,
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
        var timestamp = originalMessage.date

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

        ViewPlaceholder {
            id: viewPlaceHolder
            enabled: !accountListModel.numberOfAccounts
            //: No accounts empty state
            //% "No accounts available for email sending"
            text: qsTrId("email-la_no_send_accounts")
            //: Informs the user to configure an account capable of sending in Settings->Accounts
            //% "Please configure a sending capable account in Settings->Accounts"
            hintText: qsTrId("email-la_no_send_accounts_hint_text")
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

        PullDownMenu {
            visible: accountListModel.numberOfAccounts
            MenuItem {
                // if discardDrafs is set to false we auto-save drafts, so
                // discardDraft is shown in pulley menu, by default this property is set to true
                // so drafts are discarded.
                text: discardDraft ? _strSaveDraft : _strDiscardDraft
                enabled: messageContentModified()
                onClicked: discardDraft ? saveDraft() : _discardDraft()
            }
            MenuItem {
                text: _strAddAttach
                onClicked: modifyAttachments()
            }
            MenuItem {
                text: _strSend
                enabled: hasRecipients && (subject.text != '' || body.text != '')
                onClicked: sendMessage()
            }
        }

        PushUpMenu {
            visible: accountListModel.numberOfAccounts && flickable.contentHeight > 1.5*(isLandscape ? Screen.width : Screen.height)
            MenuItem {
                text: _strSend
                enabled: hasRecipients && (subject.text != '' || body.text != '')
                onClicked: sendMessage()
            }
            MenuItem {
                text: _strAddAttach
                onClicked: modifyAttachments()
            }
            MenuItem {
                text: _strDiscardDraft
                enabled: messageContentModified()
                onClicked: _discardDraft()
            }
        }


        Column {
            id: contentItem
            visible: accountListModel.numberOfAccounts
            y: isLandscape ? Theme.paddingMedium : 0
            width: parent.width - x

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

                            Repeater {
                                model:
                                    //: Normal priority
                                    //% "Normal"
                                    [qsTrId("jolla-email-la-priority_Normal"),
                                    //: High priority
                                    //% "High"
                                    qsTrId("jolla-email-la-priority_high"),
                                    //: Low priority
                                    //% "Low"
                                    qsTrId("jolla-email-la-priority_low")]
                                MenuItem {
                                    text: modelData
                                }
                            }
                        }

                        //: Importance label
                        //% "Importance:"
                        label: qsTrId("jolla-components_email-la-importance")
                    }
                    CompressibleItem {
                        id: attachmentsItem

                        compressible: attachmentFiles.count === 0

                        Item {
                            width: parent.width
                            // Padding small between this and subject field
                            implicitHeight: attachmentBg.height + Theme.paddingSmall

                            ListItem {
                                id: attachmentBg
                                onClicked: attachmentFiles.count === 0 ? modifyAttachments() : showAttachments()
                                enabled: !attachmentsItem.compressed
                                menu: contextMenuComponent

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
                                    opacity: 0.6

                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        right: parent.right
                                        rightMargin: Theme.horizontalPageMargin - Theme.paddingMedium
                                    }
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
                                        id: removeItem
                                        visible: attachmentFiles.count > 0
                                        //: When plural "Remove all attachments" and singular "Remove attachment".
                                        //% "Remove attachment"
                                        text: qsTrId("jolla-email-me-remove_all_attachments", attachmentFiles.count)
                                        onClicked: {
                                            attachmentFiles.clear()
                                            attachments.text = ""
                                        }
                                    }
                                    MenuItem {
                                        id: addItem
                                        //: Add new attachment
                                        //% "Add new attachment"
                                        text: qsTrId("jolla-components_email-me-add_new_attachment")
                                        onClicked: modifyAttachments()
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
                height: Math.max(messageComposer.height - (contentItem.y + (isLandscape ? 0 : pageHeader.height) + metadata.height + expanderControl.height), implicitHeight)

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

    Binding {
        target: (cover && cover.hasOwnProperty("editorTo")) ? cover : null
        property: "editorTo"
        value: to.summary
    }

    Binding {
        target: (cover && cover.hasOwnProperty("editorBody")) ? cover : null
        property: "editorBody"
        value: body.text
    }

    Component {
        id: contentPicker

        MultiContentPickerDialog {
            //: Attach files
            //% "Attach files"
            title: qsTrId("jolla-components_email-he-attach-files")
        }
    }

    EmailAccountListModel {
        id: accountListModel
        canTransmitAccounts: true
    }

    function _updateAttachmentText() {
        var names = []
        for (var i=0; i<attachmentFiles.count; ++i) {
            names.push(attachmentFiles.get(i).title)
            attachments.text = names.join(", ")
            if (attachments.implicitWidth > attachments.width) {
                while (names.length > 1 && attachments.implicitWidth > attachments.width) {
                    names.pop()
                    //: Number of additional attachments that are not currently shown
                    //% "%n other(s)"
                    var more = qsTrId("jolla-components_email-la-attchements_summary", attachmentFiles.count - names.length)
                    attachments.text = names.join(", ") + ", " + more
                }
                break
            }
        }

        // This format is used in case above loop produces too long format.
        if (attachments.implicitWidth > attachments.width) {
            //: Number of attachments, should have singular and plurar formats. Text should be relatively short (max 24 chars).
            //% "%n attachment(s)"
            attachments.text = qsTrId("jolla-components_email-la-attchements", attachmentFiles.count)
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
                    setOriginalMessageAttachments()

                    // to be removed, just temporary to provide at least same functionality as before
                    body.text = forwardPrecursor()
                    body.quote = originalMessage.quotedBody + signature
                    // Append max 10000 chars from the quote
                    body.appendQuote(10000)
                } else {
                    // Not translated:
                    if (subjectText.slice(0, 3) != 'Re:') {
                        subjectText = 'Re: ' + subjectText
                    }
                    var replyTo = originalMessage.replyTo ? originalMessage.replyTo : originalMessage.fromAddress
                    to.setRecipients(replyTo)
                    if (action == 'replyAll') {
                        message.responseType = EmailMessage.ReplyToAll
                        var tmpRecipients = originalMessage.recipients
                        // tmpRecipients is a QML intermediate(v8-sequence-wrapper) that makes splice not work correctly
                        // this should be fixed under Qt 5.2, see:
                        // http://qt-project.org/doc/qt-5.1/qtqml/qtqml-cppintegration-data.html#sequence-type-to-javascript-array
                        var recipients = tmpRecipients.slice()
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
                if(draft) {
                    setOriginalMessageAttachments()
                }
            }

            importance.currentIndex = (priority === EmailMessage.HighPriority) ? 1 : (priority === EmailMessage.LowPriority) ? 2 : 0

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
}
