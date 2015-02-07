import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0
import "contactcard/ContactsDBusService.js" as ContactsService

Page {
    id: root

    // Assign either of these to set the displayed contact. If the contactId is
    // set, contactLoaded is set to true once the contact is loaded from the contactId.
    property alias contact: contactCard.contact
    property int contactId

    property bool contactLoaded

    // Assign one if available to avoid creating a new model.
    property PeopleModel peopleModel

    property bool handleDelete: true
    property bool handleEdit: true

    property alias activeDetail: contactCard.activeDetail
    property alias readOnly: contactCard.readOnly

    property Item _remorsePopup

    signal editRequested()
    signal deleteRequested()

    function showEditor() {
        ContactsService.editContact(contactId)
    }

    function deleteContact() {
        if (_remorsePopup === null) {
            _remorsePopup = remorsePopupComponent.createObject(root)
        }
        //: Deleting contact in 5 seconds
        //% "Deleting contact"
        _remorsePopup.execute(qsTrId("components_contacts-la-removing_contact"),
            function() {
                _peopleModel().removePerson(contact)
                pageStack.pop()
            }
        )
    }

    function _peopleModel() {
        if (peopleModel == null)
            peopleModel = peopleModelComponent.createObject(root)
        return peopleModel
    }

    function _contactComplete() {
        contact.completeChanged.disconnect(_contactComplete)
        if (status === PageStatus.Activating || status === PageStatus.Active) {
            _updateContactInfo()
        }
        contactLoaded = true
    }

    function _updateContactInfo() {
        contactCard.refreshDetails()
    }

    function vCardName(person) {
        // Return a name for this vcard that can be used as a filename

        // Remove any whitespace
        var noWhitespace = person.displayLabel.replace(/\s/g, '')

        // Convert to 7-bit ASCII
        var sevenBit = Format.formatText(noWhitespace, Formatter.Ascii7Bit)
        if (sevenBit.length < noWhitespace.length) {
            // This contact's name is not representable in ASCII
            //: Placeholder name for contact vcard filename
            //% "contact"
            sevenBit = qsTrId("components_contacts-ph-vcard_name")
        }

        // Remove any characters that are not part of the portable filename character set
        return Format.formatText(sevenBit, Formatter.PortableFilename) + '.vcf'
    }

    onContactIdChanged: {
        if (contact && !contact.complete) {
            contact.completeChanged.disconnect(_contactComplete)
        }

        contact = _peopleModel().personById(contactId)
    }

    onContactChanged: {
        contactLoaded = false

        if (!contact) {
        } else if (!contact.complete) {
            contact.completeChanged.connect(_contactComplete)
        } else {
            if (status === PageStatus.Activating || status === PageStatus.Active) {
                _updateContactInfo()
            }
            contactLoaded = true
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Activating && contact && contact.complete) {
            _updateContactInfo()
        }
    }

    Component {
        id: remorsePopupComponent
        RemorsePopup {}
    }

    Component {
        id: peopleModelComponent
        PeopleModel { filterType: PeopleModel.FilterAll }
    }

    ContactCard {
        id: contactCard
        onContactModified: _peopleModel().savePerson(contact)

        PullDownMenu {
            id: menu

            MenuItem {
                //: Deletes contact
                //% "Delete"
                text: qsTrId("components_contacts-me-delete")
                onClicked: {
                    if (root.handleDelete) {
                        root.deleteContact()
                    } else {
                        root.deleteRequested()
                    }
                }
            }

            MenuItem {
                //: Manage links (associated contacts) for this contact
                //% "Link"
                text: qsTrId("components_contacts-me-link")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ContactLinksPage.qml"),
                                   {"person": contactCard.contact, "peopleModel": root.peopleModel})
                }
            }

            MenuItem {
                //: Share contact via Bluetooth, Email, etc.
                //% "Share"
                text: qsTrId("components_contacts-me-share")
                onClicked: {
                    var content = {
                        "data": contactCard.contact.vCard(),
                        "name": root.vCardName(contactCard.contact),
                        "type": "text/vcard",
                        "icon": contactCard.contact.avatarPath.toString()
                    }
                    pageStack.push(Qt.resolvedUrl("ContactSharePage.qml"), {"content": content})
                }
            }

            MenuItem {
                //: Edit contact
                //% "Edit"
                text: qsTrId("components_contacts-me-edit")
                onClicked: {
                    // While the menu is closing, the indicator opacity is reduced - close to prevent
                    menu.cancelBounceBack()
                    menu.close()

                    if (root.handleEdit) {
                        root.showEditor()
                    } else {
                        root.editRequested()
                    }
                }
            }
        }
    }
}
