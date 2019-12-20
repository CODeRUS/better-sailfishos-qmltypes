import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0 as SailfishContacts
import org.nemomobile.contacts 1.0

Page {
    id: root

    property alias contact: contactCard.contact

    // Whether to show the pulley menu with Delete, Share, Edit etc.
    property alias actionsEnabled: menu.visible

    property alias activeDetail: contactCard.activeDetail
    property alias readOnly: contactCard.readOnly

    function showError(errorText) {
        if (errorText) {
            errorLabel.text = errorText
            contactLoadingBusy.running = false
        }
    }

    function _contactComplete() {
        contact.completeChanged.disconnect(_contactComplete)
        if (status === PageStatus.Activating || status === PageStatus.Active) {
            _updateContactInfo()
        }
    }

    function _updateContactInfo() {
        contactCard.refreshDetails()
    }

    onContactChanged: {
        if (!contact) {
            contactLoadingBusy.running = false
        } else if (!contact.complete) {
            contact.completeChanged.connect(_contactComplete)
        } else {
            if (status === PageStatus.Activating || status === PageStatus.Active) {
                _updateContactInfo()
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Activating && contact && contact.complete) {
            _updateContactInfo()
        }
    }

    BusyIndicator {
        id: contactLoadingBusy

        anchors.centerIn: parent

        size: BusyIndicatorSize.Large
        running: contact == null
    }

    Label {
        id: errorLabel

        x: Theme.horizontalPageMargin
        width: parent.width - Theme.horizontalPageMargin*2
        anchors.centerIn: parent

        //% "Contact not found"
        text: qsTrId("components_contacts-la-contact_not_found")
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Theme.fontSizeLarge
        color: Theme.highlightColor
        visible: contact == null && !contactLoadingBusy.running
    }

    ContactCard {
        id: contactCard

        visible: !contactLoadingBusy.running && !errorLabel.visible
        opacity: 1 - contactLoadingBusy.opacity

        ContactCardPullDownMenu {
            id: menu

            visible: contact != null
            page: root
            contact: contactCard.contact
        }
    }
}
