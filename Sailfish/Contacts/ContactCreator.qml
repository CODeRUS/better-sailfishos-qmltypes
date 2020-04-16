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

            if (attributes.hasOwnProperty('note')) {
                details.push({
                    'type': Person.NoteType,
                    'subTypes': [ Person.NoSubType ],
                    'label': Person.NoLabel,
                    'note': attributes['note'][0],
                    'index': -1
                })
                lastCreatedContact.noteDetails = details
                details = []
            }

            if (attributes.hasOwnProperty('postal')) {
                details.push({
                    'type': Person.AddressType,
                    'subTypes': [ Person.AddressSubTypePostal ],
                    'label': Person.NoLabel,
                    'address': attributes['postal'][0],
                    'index': -1
                })
                lastCreatedContact.addressDetails = details
                details = []
            }

            if (attributes.hasOwnProperty('nickname')) {
                details.push({
                    'type': Person.NicknameType,
                    'subTypes': [ Person.NoSubType ],
                    'label': Person.NoLabel,
                    'nickname': attributes['nickname'][0],
                    'index': -1
                })
                lastCreatedContact.nicknameDetails = details
                details = []
            }

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
