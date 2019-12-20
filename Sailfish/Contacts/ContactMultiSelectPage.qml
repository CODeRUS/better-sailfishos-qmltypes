import QtQuick 2.5
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import org.nemomobile.contacts 1.0

Page {
    id: root
    allowedOrientations: Orientation.All

    property ContactSelectionModel selectedContacts: contactBrowser.selectedContacts
    property alias requiredProperty: contactBrowser.requiredContactProperty
    property alias recentContactsCategoryMask: contactBrowser.recentContactsCategoryMask
    property alias searchActive: contactBrowser.searchActive

    signal contactClicked(var contact)
    signal shareClicked(var content)
    signal deleteClicked(var contacts)

    function _deleteSelection() {
        var allSelectedContacts = []
        for (var i = 0; i < root.selectedContacts.count; ++i) {
            allSelectedContacts.push(contactBrowser.allContactsModel.personById(root.selectedContacts.get(i)))
        }
        root.deleteClicked(allSelectedContacts)
    }

    function _shareSelection() {
        // share all of the selected contacts
        var vcardName = "" + root.selectedContacts.count + "-contacts.vcf"
        var vcardData = ""
        for (var i = 0; i < root.selectedContacts.count; ++i) {
            vcardData = vcardData + contactBrowser.allContactsModel.personById(root.selectedContacts.get(i)).vCard()
        }
        vcardData = vcardData + "\r\n"
        var content = {
            "data": vcardData,
            "name": vcardName,
            "type": "text/vcard"
        }
        root.shareClicked(content)
    }

    function _doSelectionOperation(selectAll) {
        contactBrowser.selectedContacts.removeAllContacts()
        if (selectAll) {
            var currentIndex = 0
            var lastIndex = contactBrowser.allContactsModel.count - 1
            while (currentIndex <= lastIndex) {
                contactBrowser.selectedContacts.addContact(
                        contactBrowser.allContactsModel.get(
                                currentIndex,
                                PeopleModel.ContactIdRole),
                        null, null,
                        currentIndex != lastIndex
                                ? ContactSelectionModel.BatchMode
                                : ContactSelectionModel.SingleContactMode)
                currentIndex++
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active && !forwardNavigation) {
            pageStack.pushAttached(selectedContactsComponent)
        }
    }

    ContactBrowser {
        id: contactBrowser

        clip: true
        height: undefined // reset height binding to allow use anchors insteaed
        anchors { top: parent.top; bottom: controlPanel.top }
        canSelect: true
        symbolScroller.bottomMargin: controlPanel.height - controlPanel.visibleSize

        pageHeader: PageHeader {
            id: browserPageHeader

            page: root
            title: root.selectedContacts.count > 0
                    //: Indicates number of selected contacts
                    //% "%n selected"
                   ? qsTrId("components_pickers-la-count_selected", root.selectedContacts.count)
                    //: Hint that the user should select contacts
                    //% "Select contacts"
                   : qsTrId("components_pickers-la-select_contacts")

            _titleItem.color: headerMouseArea.containsPress ? Theme.highlightColor : Theme.primaryColor

            MouseArea {
                id: headerMouseArea
                parent: browserPageHeader._titleItem
                anchors.fill: parent

                onClicked: {
                    pageStack.navigateForward(PageStackAction.Animated)
                }
            }
        }

        PullDownMenu {
            MenuItem {
                enabled: contactBrowser.selectedContacts.count != contactBrowser.allContactsModel.count
                //: Select all contacts
                //% "Select all"
                text: qsTrId("components_contacts-me-select_all")
                onDelayedClick: {
                    _doSelectionOperation(true)
                }
            }

            MenuItem {
                enabled: contactBrowser.selectedContacts.count != 0
                //: Clear contacts selection
                //% "Clear all"
                text: qsTrId("components_contacts-me-clear_all")
                onDelayedClick: {
                    _doSelectionOperation(false)
                }
            }
        }

        onContactClicked: root.contactClicked(contact)
    }

    ContactSelectionDockedPanel {
        id: controlPanel

        open: root.selectedContacts.count > 0

        onDeleteClicked: root._deleteSelection()
        onShareClicked: root._shareSelection()
    }

    Component {
        id: selectedContactsComponent

        Page {
            SilicaListView {
                id: selectedContactsList

                width: parent.width
                height: parent.height - (selectionControlPanel.visibleSize)
                clip: true

                header: PageHeader {
                    //% "Selected contacts"
                    title: qsTrId("components_pickers-la-selected_contacts")
                }

                model: contactBrowser.selectedContacts

                delegate: ContactItem {
                    id: contactDelegate

                    property var contact: contactBrowser.allContactsModel.personById(model.contactId)
                    firstText: contact.primaryName
                    secondText: contact.secondaryName
                    unnamed: contact.primaryName == contactBrowser.allContactsModel.placeholderDisplayLabel

                    onClicked: {
                        var props = {
                            "contact": contact,
                            "actionsEnabled": false
                        }
                        pageStack.animatorPush(Qt.resolvedUrl("ContactCardPage.qml"), props)
                    }

                    IconButton {
                        id: clearButton
                        anchors {
                            right: parent.right
                            rightMargin: Theme.horizontalPageMargin
                        }
                        height: parent.height
                        icon.source: "image://theme/icon-m-clear"
                        highlighted: down || contactDelegate.highlighted
                        opacity: selectedContactsList.quickScrollVisible ? 0 : 1
                        Behavior on opacity { FadeAnimation { duration: 400 } }

                        onClicked: {
                            contactBrowser.selectedContacts.removeContactAt(model.index)
                        }
                    }
                }

                VerticalScrollDecorator {}

                ViewPlaceholder {
                    //% "No contacts selected"
                    text: qsTrId("components_pickers-la-no_contacts_selected")
                    enabled: contactBrowser.selectedContacts.count === 0
                }
            }

            ContactSelectionDockedPanel {
                id: selectionControlPanel

                open: root.selectedContacts.count > 0

                onDeleteClicked: root._deleteSelection()
                onShareClicked: root._shareSelection()
            }
        }
    }
}
