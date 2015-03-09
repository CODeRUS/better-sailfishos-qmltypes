import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0
import "common/common.js" as CommonJs

ContactItem {
    id: contactItem

    // Use getPerson() to access the person object so one isn't instantiated unnecessarily
    property int contactId
    property var peopleModel: ListView.view.model

    property var selectionModel
    property bool selected: selectionModel !== null && selectionModel.findContactId(contactId) >= 0

    highlighted: down || menuOpen || selected
    showMenuOnPressAndHold: false

    ContactAddressesModel {
        id: addressesModel
    }

    function remove(contactIdCheck) {
        if (contactId && peopleModel && getPerson()) {
            if (contactIdCheck != undefined && contactId != contactIdCheck) {
                return
            }

            // Retrieve the person to delete; it will be no longer accessible if the
            // remorse function is triggered by delegate destruction
            var person = getPerson()

            //: Deleting in n seconds
            //% "Deleting"
            remorseAction(qsTrId("components_contacts-la-deleting"), function () {
                peopleModel.removePerson(person)
            })
        }
    }

    function _contactClicked(contact, itemY, property, propertyType) {
        _toggleSelection(contact, property, propertyType)
        _contactItemClicked(contactItem, itemY, contact, property, propertyType)
    }

    function _toggleSelection(contact, property, propertyType) {
        if (selectionModel) {
            var selectionIndex = selectionModel.findContact(contact)
            if (selectionIndex >= 0) {
                selectionModel.removeContactAt(selectionIndex)
            } else {
                var formattedName = Format._joinNames(firstText, secondText)
                selectionModel.addContact(contact, !contact.favorite, formattedName, property, propertyType)
            }
        }
    }

    function _showContextMenu(menuItem) {
        // Don't reuse any menu, since we may show either of two different context menus
        _menuItem = menuItem
        showMenu()
    }

    onPressAndHold: {
        if (menu && getPerson()) {
            // Don't reuse any menu, since we may show either of two different context menus
            _showContextMenu(menu.createObject(contactItem, {"person": getPerson()}))
        }
    }
    onClicked: {
        var itemY = mapToItem(pageStack, 0, 0).y
        var selectedProperty
        var selectedPropertyType = ""

        addressesModel.setAddresses(getSelectableProperties())

        if (!selected && addressesModel.count) {
            if (addressesModel.count > 1) {
                // Select a specific property via menu
                var properties = { 'person': getPerson(), 'clickedItemY': itemY }
                _showContextMenu(propertyMenuComponent.createObject(contactItem, properties))
                return
            }

            selectedProperty = addressesModel.get(0).property
            selectedPropertyType = addressesModel.get(0).type
        }

        _contactClicked(getPerson(), itemY, selectedProperty, selectedPropertyType)
    }

    Component {
        id: propertyMenuComponent

        ContextMenu {
            id: contextMenu

            property Person person
            property real clickedItemY

            Repeater {
                id: repeater
                model: addressesModel

                MenuItem {
                    text: displayLabel
                    truncationMode: TruncationMode.Fade
                    onClicked: _contactClicked(contextMenu.person, contextMenu.clickedItemY, property, type)
                }
            }
        }
    }
}
