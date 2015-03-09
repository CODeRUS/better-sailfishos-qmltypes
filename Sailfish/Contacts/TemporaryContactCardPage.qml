import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0
import "contactcard/ContactsDBusService.js" as ContactsService

Page {
    id: contactPage
    allowedOrientations: Orientation.All

    property alias contact: contactCard.contact
    property alias activeDetail: contactCard.activeDetail
    property bool exitAfterSave: true

    Component.onCompleted: contacts.matchContact()

    PeopleModel {
        id: contacts

        filterType: PeopleModel.FilterAll

        function matchContact() {
            if (populated && contactCard.contact && contactCard.contact.id === 0) {
                var person
                var detail
                if (contactCard.contact.phoneDetails.length) {
                    detail = contactCard.contact.phoneDetails[0].number
                    person = personByPhoneNumber(detail, true)
                } else if (contactCard.contact.emailDetails.length) {
                    detail = contactCard.contact.emailDetails[0].address
                    person = personByEmailAddress(detail, true)
                } else if (contactCard.contact.accountDetails.length) {
                    detail = contactCard.contact.accountDetails[0].accountUri
                    person = personByOnlineAccount(contactCard.contact.accountDetails[0].accountPath, detail, true)
                }
                if (person) {
                    contactCard.contact = person
                    contactCard.activeDetail = detail
                }
            }
        }

        onPopulatedChanged: matchContact()
    }

    ContactCard {
        id: contactCard
        anchors.fill: parent
        readOnly: true
        onContactModified: contacts.savePerson(contact)

        PullDownMenu {
            id: menu

            property bool exitOnClose
            onActiveChanged: {
                if (!active && exitOnClose) {
                    // Return to anchor page if we're attached, or pop entirely
                    pageStack.navigateBack()
                }
            }

            MenuItem {
                // Defined in ContactCardPage.qml
                text: qsTrId("components_contacts-me-edit")
                onClicked: ContactsService.editContact(contact.id)
                visible: contact !== null && contact.id
            }
            MenuItem {
                // Defined in ContactCardPage.qml
                text: qsTrId("components_contacts-me-link")
                onClicked: pageStack.push(contactPickerComponent)
                visible: contact === null || !contact.id
            }
            MenuItem {
                //: Save contact
                //% "Save"
                text: qsTrId("components_contacts-me-save")
                onClicked: {
                    var properties = {}
                    if (contact.phoneDetails.length) {
                        properties["phoneNumbers"] = contact.phoneDetails[0].number
                    } else if (contact.emailDetails.length) {
                        properties["emailAddresses"] = contact.emailDetails[0].address
                    } else if (contact.accountDetails.length) {
                        properties["accountUris"] = contact.accountDetails[0].accountUri
                    }
                    ContactsService.createContact(properties)

                    if (exitAfterSave) {
                        // After saving, the source model should update but our temporary contact
                        // won't, so pop the temporary card page
                        menu.exitOnClose = true
                    }
                }
                visible: contact === null || !contact.id
            }
        }
    }

    Component {
        id: contactPickerComponent
        ContactSelectPage {
            showSearchPatternAsNewContact: false
            allContactsModel: contacts

            property Person selectedContact

            function appendDetail() {
                var detail
                if (contactPage.contact.phoneDetails.length) {
                    detail = contactPage.contact.phoneDetails[0].number

                    var details = selectedContact.phoneDetails
                    details.push({
                        'number': detail,
                        'type': Person.PhoneNumberType,
                        'index': -1
                    })
                    selectedContact.phoneDetails = details
                } else if (contactPage.contact.emailDetails.length) {
                    detail = contactPage.contact.emailDetails[0].address

                    var details = selectedContact.emailDetails
                    details.push({
                        'address': detail,
                        'type': Person.EmailAddressType,
                        'index': -1
                    })
                    details.push(detail)
                    selectedContact.emailDetails = details
                } else if (contactPage.contact.accountDetails.length) {
                    detail = contactPage.contact.accountDetails[0].accountUri

                    var details = selectedContact.accountDetails
                    details.push({
                        'accountUri': detail,
                        'type': Person.OnlineAccountType,
                        'index': -1
                    })
                    details.push(detail)
                    selectedContact.accountDetails = details
                }

                allContactsModel.savePerson(selectedContact)
                contactPage.contact = selectedContact
                contactCard.activeDetail = detail

                // Pop back to the contact card, or its predecessor
                var target = exitAfterSave ? pageStack.previousPage(contactPage) : contactPage
                pageStack.pop(target)
            }

            function appendDetailAsync() {
                if (selectedContact.complete) {
                    selectedContact.completeChanged.disconnect(appendDetailAsync)
                    appendDetail()
                }
            }

            onContactClicked: {
                selectedContact = contact
                if (selectedContact.complete) {
                    appendDetail()
                } else {
                    selectedContact.completeChanged.connect(appendDetailAsync)
                }
            }
        }
    }
}
