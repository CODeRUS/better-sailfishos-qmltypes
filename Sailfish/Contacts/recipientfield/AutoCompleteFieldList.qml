import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0
import "../common/common.js" as ContactsUtils

Item {
    id: root

    property string placeholderText
    property Page peoplePicker
    property string summary
    property int focusedChildCount
    property alias recipientsModel: recipientsModel
    property bool editing
    property int animatingCount
    property Item lastEdited
    property Item _focusTarget
    property int inputMethodHints
    property bool showLabel: true
    property bool multipleAllowed: true

    onFocusedChildCountChanged: {
        editing = (focusedChildCount > 0)
    }

    onAnimatingCountChanged: {
        if (animatingCount == 0 && _focusTarget) {
            _focusTarget.forceActiveFocus()
            _focusTarget = null
        }
    }

    onMultipleAllowedChanged: {
        if (peoplePicker) {
            peoplePicker.destroy()
            peoplePicker = null
        }
    }

    signal selectionChanged()
    signal lastFieldExited()

    function forceActiveFocus() {
        if (!entriesRepeater.count) {
            recipientsModel.append({ "person": undefined, "formattedNameText": "", "property": {}, "propertyType": "" })
        }
        entriesRepeater.itemAt(entriesRepeater.count - 1).forceActiveFocus()
    }

    function clearFocus() {
        for (var i = 0; i < entriesRepeater.count; i++) {
            entriesRepeater.itemAt(i).clearFocus()
        }
        editing = false
        _focusTarget = null
    }

    function recipientsToString() {
        var addresses = []
        for (var i = 0; i < recipientsModel.count; i++) {
            var modelItem = recipientsModel.get(i)
            // Some elements are empty due to the recipients editor logic
            var address = ContactsUtils.propertyAddressValue(modelItem.propertyType, modelItem.property)
            if (address) {
                addresses.push(ContactsUtils.propertyAddressValue(modelItem.propertyType, modelItem.property))
            }
        }
        return addresses.join(",")
    }

    function setEmailRecipients(addresses) {
        if (addresses.length === 0) {
            return
        }
        if (!(requiredProperty & PeopleModel.EmailAddressRequired)) {
            console.log("Cannot set email recipients without EmailAddressRequired requiredProperty")
            return
        }

        if (typeof addresses == "string") {
            addresses = addresses.split(",")
        }
        if (addresses instanceof Array) {
            for (var i=0; i < addresses.length; i++) {
                var contact = contactSearchModel.personByEmailAddress(addresses[i])
                var name = contact ? contact.displayLabel : ""
                var emailAddress = {'address': addresses[i]}
                recipientsModel.insert(recipientsModel.count > 0 ? recipientsModel.count - 1 : 0, {"property": emailAddress,
                                           "propertyType": "emailAddress", "formattedNameText": name, "person": contact})
            }
        }
        // Need to add one empty field in the end because "forceActiveFocus" assumes there's one.
        recipientsModel.append({ "person": undefined, "formattedNameText": "", "property": {}, "propertyType": "" })
        recipientsModel.updateSummary()
    }

    width: parent.width
    height: Math.max(entriesView.height, Theme.itemSizeMedium)

    InverseMouseArea {
        anchors.fill: parent
        anchors.margins: Theme.paddingSmall
        enabled: root.editing
        onClickedOutside: clearFocus()
    }

    ListModel {
        id: recipientsModel

        Component.onCompleted: {
            if (entriesRepeater.count == 0) {
                append({ "person": undefined, "formattedNameText": "", "property": {}, "propertyType": "" })
            }
        }

        function nextEditableIndex(index) {
            var nextIdx = index + 1
            while (nextIdx < entriesRepeater.count) {
                if (entriesRepeater.itemAt(nextIdx).editable) {
                    return nextIdx
                }
                nextIdx++
            }
            return -1
        }

        function previousEditableIndex(index) {
            var prevIdx = index - 1
            while (prevIdx >= 0) {
                if (entriesRepeater.itemAt(prevIdx).editable) {
                    return prevIdx
                }
                prevIdx--
            }
            return -1
        }

        function nextRecipient(index) {
            var nextIdx = nextEditableIndex(index)
            if (nextIdx !== -1) {
                entriesRepeater.itemAt(nextIdx).forceActiveFocus()
                return
            }

            if (!multipleAllowed && selectedContacts.count === 1) {
                clearFocus()
                return
            }

            var lastRecipient = count > 0 ? get(count-1) : undefined
            if (!lastRecipient || lastRecipient.property != {} || lastRecipient.formattedNameText != ""
                    || lastRecipient.person) {
                append({ "person": undefined, "formattedNameText": "", "property": {}, "propertyType": "" })
                updateSummary()
                entriesRepeater.itemAt(count-1).forceActiveFocus()
            }
        }

        function removeRecipient(index, moveFocus) {
            if (count === 1) {
                updateRecipient(0, {}, "", "", null)
                entriesRepeater.itemAt(0).clearText()
                updateSummary()
                entriesRepeater.itemAt(0).focus = false
                entriesRepeater.itemAt(0).forceActiveFocus()
            } else {
                remove(index)
                updateSummary()
                if (moveFocus) {
                    if (index == count) {
                        // removed last
                        editing = false
                    } else {
                        entriesRepeater.itemAt(Math.min(index, count - 1)).forceActiveFocus()
                    }
                }
            }
        }

        function updateRecipient(index, property, propertyType, name, contact) {
            set(index, {"property": property, "propertyType": propertyType})
            if (name != undefined) {
                set(index, {"formattedNameText": name})
            }
            if (contact != undefined) {
                set(index, {"person": contact})
            }
            updateSummary()
        }

        function updateRecipientAddress(index, property) {
            if (!property) {
                updateRecipient(index, {}, "")
            } else {
                // Assume this is a phone number, unless it has to be an email address
                if (requiredProperty == PeopleModel.EmailAddressRequired) {
                    updateRecipient(index, { 'address': property }, "emailAddress")
                } else {
                    updateRecipient(index, { 'number': property }, "phoneNumber")
                }
            }
        }

        function pickRecipients() {
            if (!root.peoplePicker) {
                var comp = Qt.createComponent(multipleAllowed ? "PeoplePicker.qml" : "PersonPicker.qml")
                if (comp.status !== Component.Ready) {
                    console.log("Error: " + comp.errorString() + "\n")
                    return
                }

                var page = comp.createObject(root, {"requiredProperty": requiredProperty})
                page.selectedRecipients.connect(addContacts)
                page.statusChanged.connect(function() {
                    if (page.status == PageStatus.Deactivating) {
                        root.forceActiveFocus()
                    }
                })

                root.peoplePicker = page
            } else {
                root.peoplePicker.clearSelections()
            }

            pageStack.push(root.peoplePicker)
        }

        function addContacts(contacts) {
            for (var i = 0; i < contacts.count; i++) {
                var selection = contacts.get(i)
                var j = 0
                for (; j < count; j++) {
                    if (get(j).property == selection.property) {
                        break;
                    }
                }
                if (j == count) {
                    var contact = selection.person
                    var props = { "property": selection.property, "propertyType": selection.propertyType,
                                  "formattedNameText": contact.displayLabel,
                                  "person": contact }
                    if (multipleAllowed) {
                        insert(count - 1, props)
                    } else {
                        set(0, props)
                    }
                }
            }
            updateSummary()
        }

        function updateSummary() {
            var tempSummary = ""
            for (var i = 0; i < count; i++) {
                var modelItem = get(i)
                var tempStr = ""
                if (modelItem.propertyType != "" && modelItem.property != {}) {
                    if (modelItem.person != undefined && modelItem.person.firstName != undefined
                            && modelItem.person.firstName != "") {
                        tempStr = modelItem.person.firstName
                    } else if (modelItem.formattedNameText != "") {
                        tempStr = modelItem.formattedNameText
                    } else {
                        tempStr = ContactsUtils.propertyAddressValue(modelItem.propertyType, modelItem.property)
                    }
                }

                if (tempStr != "") {
                    if (tempSummary != 0) {
                        tempSummary += ", "
                    }
                    tempSummary += tempStr
                }
            }
            summary = tempSummary
            root.selectionChanged()
        }
    }

    Column {
        id: entriesView
        width: root.width

        Timer {
            id: removeTimer
            property int index
            property bool moveFocus
            interval: 1
            onTriggered: {
                if (moveFocus) {
                    var moveIdx = recipientsModel.previousEditableIndex(index)
                    if (moveIdx === -1) {
                        // item will be removed before next index, compensate with "- 1"
                        moveIdx = recipientsModel.nextEditableIndex(index) - 1
                    }
                    if (moveIdx >= 0) {
                        recipientsModel.remove(index)
                        entriesRepeater.itemAt(moveIdx).forceActiveFocus()
                    }
                } else {
                    recipientsModel.remove(index)
                }
            }
        }

        Repeater {
            id: entriesRepeater

            model: recipientsModel

            AutoCompleteField {
                id: autoCompleteField
                recipientsModel: entriesRepeater.model
                width: root.width
                placeholderText: root.placeholderText
                inFocusedList: focusedChildCount > 0
                editing: root.editing && lastEdited == autoCompleteField
                addAction: (model.index == entriesRepeater.count - 1 && multipleAllowed) || !multipleAllowed
                inputMethodHints: root.inputMethodHints ? root.inputMethodHints : Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                labelVisible: model.index === recipientsModel.count - 1 && root.showLabel

                onHasFocusChanged: {
                    if (hasFocus) {
                        root.focusedChildCount++
                        root.lastEdited = autoCompleteField
                    } else {
                        root.focusedChildCount--
                    }
                }

                onNextField: {
                    if (empty && recipientsModel.count > 0) {
                        if (index === recipientsModel.count - 1) {
                            root.editing = false
                            root.lastFieldExited()
                            return
                        }
                        removeTimer.index = index
                        removeTimer.moveFocus = false
                        removeTimer.start()
                    }

                    recipientsModel.nextRecipient(index)
                }

                onBackspacePressed: {
                    if (empty && recipientsModel.count > 1) {
                        removeTimer.index = index
                        removeTimer.moveFocus = true
                        removeTimer.start()
                    }
                }

                onAnimatingChanged: {
                    if (animating) {
                        root.animatingCount++
                    } else {
                        root.animatingCount--
                    }
                }
            }
        }
    }
}
