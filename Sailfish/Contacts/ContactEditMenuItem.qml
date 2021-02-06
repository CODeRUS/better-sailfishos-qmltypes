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

    function anyConstituentWritable() {
        if (!contact.addressBook.isAggregate) {
            return false
        }
        if (contact.constituents.length === 0) {
            findConstituents.target = contact
            contact.fetchConstituents()
            return false
        }
        var constituents = contact.constituents
        for (var i = 0; i < constituents.length; ++i) {
            var constituentContact = peopleModel.personById(constituents[i])

            // If any constituent is editable, then the aggregate is considered editable.
            if (constituentContact && !constituentContact.addressBook.readOnly) {
                return true
            }
        }
        return false
    }

    //: Edit contact, from list
    //% "Edit"
    text: qsTrId("components_contacts-me-edit_contact")

    enabled: !!contact
             && (contact.id === 0 || (contact.addressBook.isAggregate
                                      ? anyConstituentWritable()
                                      : !contact.addressBook.readOnly))

    Connections {
        id: findConstituents

        target: null

        onConstituentsChanged: {
            target = null
        }
    }
}
