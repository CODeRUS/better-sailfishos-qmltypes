import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import org.nemomobile.contacts 1.0

Dialog {
    id: root
    allowedOrientations: Orientation.All

    property ListModel selectedContacts: contactBrowser.selectedContacts
    property string searchPlaceholderText: contactBrowser.searchPlaceholderText
    property bool showSearchPatternAsNewContact: false
    property alias requiredProperty: contactBrowser.requiredProperty
    property alias showRecentContactList: contactBrowser.showRecentContactList
    property alias recentContactsCategoryMask: contactBrowser.recentContactsCategoryMask
    property alias searchEnabled: contactBrowser.searchEnabled

    signal contactClicked(variant contact, variant clickedItemY, variant property, string propertyType)

    canAccept: selectedContacts.count > 0

    ContactBrowser {
        id: contactBrowser

        contactsSelectable: true
        deleteOnlyContextMenu: true
        searchEnabled: true
        focus: false
        showSearchPatternAsNewContact: root.showSearchPatternAsNewContact

        onContactClicked: root.contactClicked(contact, clickedItemY, property, propertyType)

        topContent: [
            DialogHeader {
                dialog: root
                acceptText: contactBrowser.selectedContacts.count
                        //: Indicates number of selected contacts
                        //% "%n selected"
                       ? qsTrId("components_pickers-la-count_selected", contactBrowser.selectedContacts.count)
                       : ""
                spacing: 0
            }
        ]
    }
}
