pragma Singleton
import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0 as SailfishContacts
import org.nemomobile.contacts 1.0

QtObject {
    // Keeps a reference to the last created new contact as an alternative to parenting the objects
    // which will leak instances over time.
    property var lastCreatedContact

    function createContact(attributes) {
        if (lastCreatedContact) {
            lastCreatedContact.destroy()
        }

        lastCreatedContact = _emptyContactComponent.createObject(null)
        if (attributes !== undefined) {
            var details = []
            var items = []
            var list
            var i

            if (attributes.hasOwnProperty('phoneNumbers')) {
                list = attributes['phoneNumbers']
                if (SailfishContacts.ContactsUtil.isArray(list)) {
                    items = list
                } else {
                    items.push(list)
                }
                for (i = 0; i < items.length; ++i) {
                    details.push({
                        'type': Person.PhoneNumberType,
                        'subTypes': [ Person.NoSubType ],
                        'label': Person.NoLabel,
                        'number': items[i],
                        'index': -1
                    })
                }
                if (details.length) {
                    lastCreatedContact.phoneDetails = details
                    details = []
                }
            }

            if (attributes.hasOwnProperty('emailAddresses')) {
                list = attributes['emailAddresses']
                if (SailfishContacts.ContactsUtil.isArray(list)) {
                    items = list
                } else {
                    items.push(list)
                }
                for (i = 0; i < items.length; ++i) {
                    details.push({
                        'type': Person.EmailAddressType,
                        'label': Person.NoLabel,
                        'address': items[i],
                        'index': -1
                    })
                }
                if (details.length) {
                    lastCreatedContact.emailDetails = details
                    details = []
                }
            }

            if (attributes.hasOwnProperty('accountUris')) {
                list = attributes['accountUris']
                if (SailfishContacts.ContactsUtil.isArray(list)) {
                    items = list
                } else {
                    items.push(list)
                }
                for (i = 0; i < items.length; ++i) {
                    details.push({
                        'type': Person.OnlineAccountType,
                        'subType': Person.NoSubType,
                        'label': Person.NoLabel,
                        'accountUri': items[i],
                        'index': -1
                    })
                }
                if (details.length) {
                    lastCreatedContact.accountDetails = details
                    details = []
                }
            }
        }

        return lastCreatedContact
    }

    property Component _emptyContactComponent: Component {
        Person {}
    }
}
