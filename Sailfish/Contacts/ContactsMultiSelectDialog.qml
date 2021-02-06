import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import org.nemomobile.contacts 1.0

Dialog {
    id: root
    allowedOrientations: Orientation.All

    property ContactSelectionModel selectedContacts: contactBrowser.selectedContacts
    property alias requiredProperty: contactBrowser.requiredContactProperty
    property alias recentContactsCategoryMask: contactBrowser.recentContactsCategoryMask
    property alias searchActive: contactBrowser.searchActive

    signal contactClicked(var contact, var property, string propertyType)

    function _propertySelected(contact, propertyData, contextMenu, propertyPicker) {
        root.contactClicked(contact, propertyData.property, propertyData.propertyType)
    }

    canAccept: selectedContacts.count > 0

    ContactBrowser {
        id: contactBrowser

        canSelect: true
        searchActive: true

        pageHeader: DialogHeader {
            dialog: root
            acceptText: root.selectedContacts.count > 0
                    //: Indicates number of selected contacts
                    //% "%n selected"
                   ? qsTrId("components_pickers-la-count_selected", root.selectedContacts.count)
                     //% "Select"
                   : qsTrId("components_contacts-la-select")
            spacing: 0
        }

        onContactClicked: {
            if (root.requiredProperty === PeopleModel.NoPropertyRequired) {
                root.contactClicked(contact, null, "")
            } else {
                contactBrowser.selectContactProperty(contact.id, root.requiredProperty, root._propertySelected)
            }
        }
    }
}
