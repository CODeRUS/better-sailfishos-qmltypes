/*
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
*/

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0

MenuItem {
    id: root

    property var contact
    property var peopleModel

    function allConstituentsDeletable() {
        if (!contact.addressBook.isAggregate) {
            return !contact.addressBook.readOnly
        }
        if (contact.constituents.length === 0) {
            findConstituents.target = contact
            contact.fetchConstituents()
            return false
        }
        var constituents = contact.constituents
        for (var i = 0; i < constituents.length; ++i) {
            var constituentContact = peopleModel.personById(constituents[i])

            // If any constituent is in a read-only collection, then the aggregate as a whole is
            // not considered deletable.
            if (!constituentContact || constituentContact.addressBook.readOnly) {
                return false
            }
        }
        return true
    }

    //: Deletes contact
    //% "Delete"
    text: qsTrId("components_contacts-me-delete")

    enabled: !!contact
             && contact.id !== 0
             && (contact.addressBook.isAggregate
                 ? allConstituentsDeletable()
                 : !contact.addressBook.readOnly)

    Connections {
        id: findConstituents

        target: null

        onConstituentsChanged: {
            target = null
        }
    }
}
