import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0
import "recipientfield"
import "common/common.js" as ContactsUtils

Item {
    id: root
    property alias placeholderText: namesList.placeholderText
    property string summaryPlaceholderText: placeholderText
    property alias summary: namesList.summary
    property QtObject contactSearchModel
    property bool empty: namesList.summary == ""
    // Supported properties is a combination of: PeopleModel.EmailAddressRequired, AccountUriRequired, PhoneNumberRequired
    property int requiredProperty: PeopleModel.EmailAddressRequired
    property alias multipleAllowed: namesList.multipleAllowed
    property alias inputMethodHints: namesList.inputMethodHints

    // A model with the following roles:
    // "property" - an object containing the value of the property that the user chose:
    //              a phone number { 'number' }, an email address { 'address' }, or IM account { 'uri', 'path' }
    // "propertyType" - the type of property that the user chose. Either "phoneNumber", "emailAddress" or "accountUri"
    // "formattedNameText" - the name of the contact
    // "person" - the Person object if the user chose from the known contacts
    property QtObject selectedContacts: namesList.recipientsModel

    property QtObject addressesModel: addressesModelId
    property bool _editing: namesList.editing
    property alias showLabel: namesList.showLabel

    signal finishedEditing()
    signal selectionChanged()
    signal lastFieldExited()

    function forceActiveFocus() {
        namesList.forceActiveFocus()
    }

    function recipientsToString() {
        return namesList.recipientsToString()
    }

    function setEmailRecipients(addresses) {
        namesList.setEmailRecipients(addresses)
    }

    function _addressList(contact) {
        // Ensure the import is initialized
        ContactsUtils.init(Person)
        return ContactsUtils.selectableProperties(contact, requiredProperty, Person)
    }

    onMultipleAllowedChanged: {
        if (!multipleAllowed && namesList.recipientsModel.count > 1) {
            for (var i = namesList.recipientsModel.count - 1; i > 0; i--)
                namesList.recipientsModel.removeRecipient(i)
        }
    }

    height: _editing ? namesList.height : recipientsSummary.height
    width: parent ? parent.width : Screen.width

    Binding {
        target: contactSearchModel
        property: "requiredProperty"
        value: root.requiredProperty
    }

    ContactAddressesModel {
        id: addressesModelId
        requiredProperty: root.requiredProperty
    }

    AutoCompleteFieldList {
        id: namesList
        opacity: _editing ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation {} }
        visible: opacity > 0.0
        onEditingChanged: {
            if (!editing) {
                root.finishedEditing()
            }
        }
        onSelectionChanged: root.selectionChanged()
        onLastFieldExited: root.lastFieldExited()
    }

    MouseArea {
        id: recipientsSummary

        width: parent.width
        height: Screen.sizeCategory >= Screen.Large ? Theme.itemSizeLarge : Theme.itemSizeMedium
        opacity: !_editing ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation {} }
        visible: opacity > 0.0

        onClicked: {
            if (!multipleAllowed && summaryLabel.text.length) {
                addressesModel.contact = null
                namesList.recipientsModel.removeRecipient(0, true)
            } else {
                namesList.forceActiveFocus()
            }
        }

        Label {
            id: summaryLabel
            anchors {
                left: parent.left
                leftMargin: Theme.horizontalPageMargin
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
                top: parent.top
                topMargin: Theme.paddingSmall
            }
            color: summary !== "" ? Theme.primaryColor : Theme.secondaryColor
            verticalAlignment: Text.AlignVCenter
            truncationMode: TruncationMode.Fade
            text: summary !== "" ? summary : placeholderText
        }

        Label {
            id: labelItem
            text: root.summaryPlaceholderText
            anchors {
                left: summaryLabel.left
                right: summaryLabel.right
                top: summaryLabel.bottom
                topMargin: Theme.paddingMedium
            }
            color: Theme.primaryColor
            opacity: 0.6
            visible: summary !== ""
            elide: Text.ElideRight
            font.pixelSize: Theme.fontSizeSmall
        }
        Separator {
            // Must match with separator positioning in TextField
            anchors {
                left: summaryLabel.left
                right: summaryLabel.right
                bottom: summaryLabel.bottom
                bottomMargin: -(Theme.paddingMedium - (Theme.paddingSmall / 2))
            }
            color: summaryLabel.color
        }
    }
}
