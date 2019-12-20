import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0 as SailfishContacts
import org.nemomobile.contacts 1.0

ContactCardPage {
    id: root

    property int contactId
    property var peopleModel

    property bool _loaded

    onStatusChanged: {
        if (!_loaded && contactId > 0) {
            contact = root.peopleModel.personById(contactId)
            _loaded = true
        }
    }

    // Detect when a new contact is created.
    Connections {
        target: root.contactId === 0 ? peopleModel : null

        onSavePersonSucceeded: {
            target = null
            root.contactId = aggregateId
        }

        onSavePersonFailed: {
            target = null
            //% "Unable to save contact"
            root.showError(qsTrId("components_contacts-la-contact_save_error"))
        }
    }
}
