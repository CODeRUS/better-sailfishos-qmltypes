import QtQuick 2.6
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0
import "recipientfield"
import Sailfish.Contacts 1.0 as Contacts

Item {
    id: root
    property int actionType
    property alias placeholderText: namesList.placeholderText
    property alias summaryPlaceholderText: labelItem.text
    property alias summary: namesList.summary
    readonly property alias hasFocus: namesList.editing
    property alias fullSummary: namesList.fullSummary
    property QtObject contactSearchModel
    property bool empty: namesList.summary == ""
    // Supported properties is a combination of: PeopleModel.EmailAddressRequired, AccountUriRequired, PhoneNumberRequired
    property int requiredProperty: PeopleModel.EmailAddressRequired
    property alias multipleAllowed: namesList.multipleAllowed
    property alias inputMethodHints: namesList.inputMethodHints
    property alias recentContactsCategoryMask: namesList.recentContactsCategoryMask

    // A model with the following roles:
    // "property" - an object containing the value of the property that the user chose:
    //              a phone number { 'number' }, an email address { 'address' }, or IM account { 'uri', 'path' }
    // "propertyType" - the type of property that the user chose. Either "phoneNumber", "emailAddress" or "accountUri"
    // "formattedNameText" - the name of the contact
    // "person" - the Person object if the user chose from the known contacts
    property QtObject selectedContacts: namesList.recipientsModel

    property QtObject addressesModel: addressesModelId
    property alias showLabel: namesList.showLabel

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
        return ContactsUtil.selectableProperties(contact, requiredProperty, Person)
    }

    function updateSummary() {
        namesList.updateSummary()
    }

    onMultipleAllowedChanged: {
        if (!multipleAllowed && namesList.recipientsModel.count > 1) {
            for (var i = namesList.recipientsModel.count - 1; i > 0; i--)
                namesList.recipientsModel.removeRecipient(i)
        }
    }

    height: hasFocus ? namesList.height : recipientsSummary.height
    width: parent ? parent.width : Screen.width

    Binding {
        target: contactSearchModel
        property: "requiredProperty"
        value: root.requiredProperty
    }

    ContactPropertyModel {
        id: addressesModelId
        requiredProperty: root.requiredProperty
    }

    AutoCompleteFieldList {
        id: namesList
        requiredProperty: root.requiredProperty
        opacity: editing ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation {} }
        visible: opacity > 0.0

        //: A single recipient
        //% "Recipient"
        placeholderText: qsTrId("components_contacts-ph-recipient")

        onSelectionChanged: root.selectionChanged()
        onLastFieldExited: root.lastFieldExited()
    }

    MouseArea {
        id: recipientsSummary

        width: parent.width
        height: Screen.sizeCategory >= Screen.Large ? Theme.itemSizeLarge : Theme.itemSizeMedium
        opacity: !root.hasFocus ? 1.0 : 0.0
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

        TextMetrics {
            id: fullSummaryMetrics
            font: summaryLabel.font
            text: fullSummary
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
            text: {
                if (fullSummary != "" && fullSummaryMetrics.width <= width)
                    return fullSummary
                if (summary != "")
                    return summary
                return placeholderText
            }
        }

        Label {
            id: labelItem

            //: Summary of all selected recipients, e.g. "Bob, Jane, 75553243"
            //% "Recipients"
            text: qsTrId("components_contacts-ph-recipients")

            anchors {
                left: summaryLabel.left
                right: summaryLabel.right
                top: summaryLabel.bottom
                topMargin: Theme.paddingMedium
            }
            color: Theme.secondaryColor
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
