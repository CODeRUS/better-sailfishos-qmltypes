import QtQuick 2.0
import Sailfish.Silica 1.0
import "../common/common.js" as ContactsUtils

Item {
    id: root
    property ListModel recipientsModel
    property bool addAction
    property bool inFocusedList
    property alias placeholderText: inputField.placeholderText
    property alias hasFocus: inputField.activeFocus
    property alias animating: autoCompleteAnim.running
    property bool empty: inputField.text == ""
    property bool editing
    property bool editable: !inputField.readOnly
    property alias inputMethodHints: inputField.inputMethodHints
    property alias labelVisible: inputField.labelVisible

    signal nextField()
    signal backspacePressed()

    function forceActiveFocus() {
        if (editable) {
            inputField.forceActiveFocus()
        }
    }

    function clearFocus() {
        inputField.focus = false
    }

    function clearText() {
        inputField.text = ""
    }

    width: parent.width
    height: inputField.height + (!animating ? autoComplete.height : 0)
    opacity: 0.0
    NumberAnimation on opacity { to: 1.0; running: true }

    TextField {
        id: inputField

        property string trimmedText: text.trim()

        width: parent.width - actionButton.width
        textRightMargin: Theme.paddingSmall
        label: placeholderText
        readOnly: model.formattedNameText != ""
        onReadOnlyChanged: {
            if (readOnly) {
                focus = false
            }
        }
        color: Theme.highlightColor
        placeholderColor: Theme.secondaryHighlightColor
        focusOutBehavior: FocusBehavior.KeepFocus

        focusOnClick: !readOnly
        onClicked: {
            if (readOnly && inFocusedList && !addAction) {
                addressesModel.contact = null
                recipientsModel.removeRecipient(model.index, inputField.activeFocus)
            }
        }

        function updateFromContact(contact, index) {
            var address = _addressList(contact)[index]
            recipientsModel.updateRecipient(model.index,
                                            address.property, address.propertyType,
                                            contact.displayLabel, contact)
            text = model.formattedNameText
            recipientsModel.nextRecipient(model.index)
        }

        function textValue() {
            var val = model.formattedNameText !== "" ? model.formattedNameText
                                                     : ContactsUtils.propertyAddressValue(model.propertyType, model.property)
            return val === undefined ? "" : val
        }

        EnterKey.onClicked: {
            recipientsModel.updateRecipientAddress(model.index, text)
            nextField()
        }
        EnterKey.iconSource: "image://theme/icon-m-enter-next"

        onTextChanged: {
            if (!readOnly) {
                addressesModel.contact = null
                var origText = text
                text = text.replace(/[,;]/g, "")
                if (text != origText) {
                    // Separator character found, add new recipient.
                    text = text.trim() // cannot use trimmedText here because it's not evaluated yet
                    if (text != "") {
                        recipientsModel.updateRecipientAddress(model.index, text)
                        recipientsModel.nextRecipient(model.index)
                    }
                }
                autoComplete.searchText = text
            }
        }

        onActiveFocusChanged: {
            if (activeFocus) {
                text = textValue()
            } else {
                addressesModel.contact = null
                if (model.index != -1 && !readOnly) {
                    text = trimmedText
                    recipientsModel.updateRecipientAddress(model.index, text)
                }
            }
        }

        Component.onCompleted: {
            text = textValue()
            // TODO: Replace with "Keys.onPressed" once JB#16601 is implemented.
            inputField._editor.Keys.pressed.connect(function(event) {
                if (event.key === Qt.Key_Backspace) {
                    root.backspacePressed()
                }
            })
        }
    }

    Binding {
        when: autoCompleteList.model == contactSearchModel
        target: contactSearchModel
        property: "filterPattern"
        value: autoComplete.searchText
    }

    IconButton {
        id: actionButton
        visible: root.inFocusedList && addAction
        opacity: 0.6
        anchors {
            right: parent.right
            rightMargin: Theme.paddingSmall
            verticalCenter: inputField.top
            verticalCenterOffset: inputField.textVerticalCenterOffset
        }
        icon.source: "image://theme/icon-m-add"
        onClicked: {
            addressesModel.contact = null
            recipientsModel.pickRecipients()
        }
    }

    Item {
        id: autoComplete
        property string searchText
        width: parent.width
        height: autoCompleteList.height
        anchors.top: inputField.bottom
        opacity: editing && !inputField.readOnly ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation { id: autoCompleteAnim } }

        ColumnView {
            id: autoCompleteList
            width: parent.width
            itemHeight: Theme.itemSizeSmall
            model: ((editing || animating) && addressesModel.count)
                   ? addressesModel
                   : ((editing || animating) && inputField.trimmedText != "")
                     ? contactSearchModel
                     : null

            delegate: BackgroundItem {
                id: contactItem
                width: autoCompleteList.width
                height: isPortrait ? Theme.itemSizeSmall : Theme.itemSizeExtraSmall

                property var pendingContact: null

                Label {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: Theme.paddingLarge
                        rightMargin: Theme.paddingLarge
                    }
                    truncationMode: TruncationMode.Fade
                    textFormat: Text.StyledText
                    text: Theme.highlightText(model.displayLabel, inputField.trimmedText, Theme.highlightColor)
                    color: contactItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Connections {
                    target: pendingContact
                    onCompleteChanged: {
                        if (pendingContact.complete) {
                            update()
                        }
                    }
                }

                onClicked: update()
                function update() {
                    pendingContact = null
                    var contact = null
                    var addressIndex = 0
                    if (autoCompleteList.model == contactSearchModel) {
                        contact = contactSearchModel.personByRow(model.index)
                        if (!contact.complete) {
                            pendingContact = contact
                            contact.ensureComplete()
                            return
                        }
                        var addresses = _addressList(contact)
                        if (contact && addresses.length != 1) {
                            if (addresses.length > 1) {
                                addressesModel.contact = contact
                            }
                            return
                        }
                    } else {
                        contact = addressesModel.contact
                        addressIndex = model.index
                    }
                    if (contact) {
                        inputField.updateFromContact(contact, addressIndex)
                    }
                }
            }
        }
    }
}
