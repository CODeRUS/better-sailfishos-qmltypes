/*
 * Copyright (c) 2013 - 2019 Jolla Pty Ltd.
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
*/

import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import QtQuick 2.5

ContextMenu {
    id: root

    property QtObject person
    property var peopleModel
    property bool _favorite

    signal editContact()
    signal changeFavoriteStatus(bool favorite)

    onActiveChanged: {
        if (active) {
            _favorite = person.favorite
        }
    }

    ContactEditMenuItem {
        contact: root.person
        peopleModel: root.peopleModel

        onClicked: root.editContact()
    }

    MenuItem {
        text: root._favorite
              //: Set contact as not favorite
              //% "Remove from favorites"
            ? qsTrId("components_contacts-me-remove_contact_from_favorites")
              //: Set contact as favorite
              //% "Add to favorites"
            : qsTrId("components_contacts-me-add_contact_to_favorites")

        // Delay click action to prevent menu open/close from affecting favorite/recent list
        // height calculations.
        onClicked: {
            root.person = ContactsUtil.ensureContactComplete(root.person, root.peopleModel)
            root.changeFavoriteStatus(!person.favorite)
        }
    }

    ContactDeleteMenuItem {
        //% "Delete contact"
        text: qsTrId("components_contacts-me-delete_contact")
        contact: root.person
        peopleModel: root.peopleModel
        visible: root.parent && root.parent.canDeleteContact

        onClicked: root.parent.deleteContact()
    }
}
