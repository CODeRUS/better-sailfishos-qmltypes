import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import QtQuick 2.5

ContextMenu {
    id: root

    property QtObject person
    property var peopleModel
    property bool _favorite

    signal editContact()

    onActiveChanged: {
        if (active) {
            _favorite = person.favorite
        }
    }

    MenuItem {
        //: Edit contact, from list
        //% "Edit"
        text: qsTrId("components_contacts-me-edit_contact")
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
        onDelayedClick: {
            root.person = ContactsUtil.ensureContactComplete(root.person, root.peopleModel)
            person.favorite = !root._favorite
            peopleModel.savePerson(person)
        }
    }

    MenuItem {
        //% "Delete contact"
        text: qsTrId("components_contacts-me-delete_contact")
        visible: root.parent && root.parent.canDeleteContact

        onClicked: root.parent.deleteContact()
    }
}
