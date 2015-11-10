import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.contacts 1.0

Page {
    id: root
    allowedOrientations: Orientation.All

    property string searchPlaceholderText: contactBrowser.searchPlaceholderText
    property bool showSearchPatternAsNewContact: false
    property alias allContactsModel: contactBrowser.allContactsModel
    property alias requiredProperty: contactBrowser.requiredProperty
    property alias showRecentContactList: contactBrowser.showRecentContactList
    property alias recentContactsCategoryMask: contactBrowser.recentContactsCategoryMask
    property alias searchEnabled: contactBrowser.searchEnabled
    property bool searchMenuEnabled

    property string title: requiredProperty == PeopleModel.PhoneNumberRequired ?
                           //: Page title of contact phone number selector
                           //% "Select number"
                           qsTrId("components_pickers-he-select_phone_number") :
                           (requiredProperty == PeopleModel.EmailAddressRequired ?
                           //: Page title of contact email address selector
                           //% "Select email"
                           qsTrId("components_pickers-he-select_email_address") :
                           //: Page title of contact selector
                           //% "Select contact"
                           qsTrId("components_pickers-he-select_contact"))

    signal contactClicked(variant contact, variant clickedItemY, variant property, string propertyType)

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            // Apply the current value of searchConfig
            contactBrowser.searchEnabled = (searchConfig.value == 1)
        }
    }

    ConfigurationValue {
        id: searchConfig
        key: "/desktop/sailfish/contacts/search_enabled"
        defaultValue: 0
    }

    ContactBrowser {
        id: contactBrowser

        contactsSelectable: false
        searchEnabled: false
        focus: false
        showSearchPatternAsNewContact: root.showSearchPatternAsNewContact

        onContactClicked: root.contactClicked(contact, clickedItemY, property, propertyType)

        topContent: [
            PageHeader {
                title: root.title
            }
        ]

        PullDownMenu {
            id: menu

            visible: searchMenuEnabled
            enabled: contactBrowser.allContactsModel.count > 0

            // Don't change the menu text while the menu is open
            property bool _searchEnabled
            onActiveChanged: {
                if (active) {
                    _searchEnabled = contactBrowser.searchEnabled
                }
            }

            MenuItem {
                                          //: Hide contact search view
                                          //% "Hide search"
                text: menu._searchEnabled ? qsTrId("components_pickers-me-hide_search")
                                          //: Show contact search view
                                          //% "Show search"
                                          : qsTrId("components_pickers-me-show_search")

                onClicked: contactBrowser.searchEnabled = !contactBrowser.searchEnabled
            }
        }
    }
}
