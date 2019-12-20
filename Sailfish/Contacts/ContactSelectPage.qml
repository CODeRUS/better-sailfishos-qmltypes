import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import org.nemomobile.contacts 1.0

Page {
    id: root
    allowedOrientations: Orientation.All

    property alias allContactsModel: contactBrowser.allContactsModel
    property alias requiredProperty: contactBrowser.requiredContactProperty
    property alias recentContactsCategoryMask: contactBrowser.recentContactsCategoryMask
    property alias searchActive: contactBrowser.searchActive

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

    signal contactClicked(var contact, var property, string propertyType)

    function _propertySelected(contact, propertyData, contextMenu, propertyPicker) {
        root.contactClicked(contact, propertyData.property, propertyData.propertyType)
    }

    ContactBrowser {
        id: contactBrowser

        canSelect: false
        searchActive: true

        onContactClicked: {
            if (root.requiredProperty === PeopleModel.NoPropertyRequired) {
                root.contactClicked(contact, null, "")
            } else {
                contactBrowser.selectContactProperty(contact.id, root.requiredProperty, root._propertySelected)
            }
        }

        pageHeader: PageHeader {
            title: root.title
        }

        PullDownMenu {
            id: menu

            visible: contactBrowser.allContactsModel.count > 0

            MenuItem {
                //: Show contact search view
                //% "Search"
                text: qsTrId("components_pickers-me-search")
                onClicked: contactBrowser.forceSearchFocus()
            }
        }
    }
}
