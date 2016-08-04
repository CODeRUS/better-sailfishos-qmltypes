import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import org.nemomobile.contacts 1.0

Page {
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
    signal shareClicked(var content)
    signal deleteClicked(var contacts)

    ContactBrowser {
        id: contactBrowser

        clip: true
        height: undefined // reset height binding to allow use anchors insteaed
        anchors { top: parent.top; bottom: controlPanel.top }
        contactsSelectable: true
        deleteOnlyContextMenu: true
        searchEnabled: false
        focus: false
        showSearchPatternAsNewContact: root.showSearchPatternAsNewContact

        onContactClicked: root.contactClicked(contact, clickedItemY, property, propertyType)

        topContent: [
            PageHeader {
                page: root
                title: contactBrowser.selectedContacts.count
                        //: Indicates number of selected contacts
                        //% "%n selected"
                       ? qsTrId("components_pickers-la-count_selected", contactBrowser.selectedContacts.count)
                       : ""
            }
        ]
    }

    DockedPanel {
        id: controlPanel
        width: parent.width
        height: Theme.itemSizeLarge
        dock: Dock.Bottom
        open: root.selectedContacts.count > 0

        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            source: "image://theme/graphic-gradient-edge"
        }
        Row {
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            IconButton {
                width: parent.width/2
                icon.source: "image://theme/icon-m-delete"
                onClicked: {
                    var allSelectedContacts = []
                    for (var i = 0; i < root.selectedContacts.count; ++i) {
                        allSelectedContacts.push(root.selectedContacts.get(i).person)
                    }
                    root.deleteClicked(allSelectedContacts)
                }
            }

            IconButton {
                width: parent.width/2
                icon.source: "image://theme/icon-m-share"
                onClicked: {
                    // share all of the selected contacts
                    var vcardName = "" + root.selectedContacts.count + "-contacts.vcf"
                    var vcardData = ""
                    for (var i = 0; i < root.selectedContacts.count; ++i) {
                        vcardData = vcardData + root.selectedContacts.get(i).person.vCard()
                    }
                    vcardData = vcardData + "\r\n"
                    var content = {
                        "data": vcardData,
                        "name": vcardName,
                        "type": "text/vcard"
                    }
                    root.shareClicked(content)
                }
            }
        }
    }
}
