import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Telephony 1.0
import org.nemomobile.contacts 1.0
import "common/common.js" as CommonJs

ContactItem {
    id: contactItem

    // Use getPerson() to access the person object so one isn't instantiated unnecessarily
    property int contactId

    // Telephony.Call or Telephony.Message
    property int actionType: Telephony.Call
    property var peopleModel: ListView.view.model

    property var selectionModel
    property bool selected: selectionModel !== null && selectionModel.findContactId(contactId) >= 0
    property bool recent
    property bool promptSimSelection: Telephony.voiceSimUsageMode === Telephony.AlwaysAskSim

    highlighted: down || menuOpen || selected
    openMenuOnPressAndHold: false

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
            var model = peopleModel

            //: Deleting in n seconds
            //% "Deleting"
            remorseAction(qsTrId("components_contacts-la-deleting"), function () {
                model.removePerson(person)
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
        openMenu()
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

        if (selectedPropertyType == 'phoneNumber' && promptSimSelection) {
            // Select a SIM via menu
            properties = { 'person': getPerson(), 'clickedItemY': itemY, 'property': selectedProperty, 'type': selectedPropertyType, 'simPickerActive': true }
            _showContextMenu(propertyMenuComponent.createObject(contactItem, properties))
            return
        }

        _contactClicked(getPerson(), itemY, selectedProperty, selectedPropertyType)
    }

    Component {
        id: propertyMenuComponent

        ContextMenu {
            id: contextMenu

            property Person person
            property real clickedItemY
            property var property
            property string type
            property alias simPickerActive: simPicker.active

            SimPickerMenuItem {
                id: simPicker
                menu: contextMenu
                actionType: contactItem.actionType
                fadeAnimationEnabled: addressesModel.count > 1
                onSimSelected: {
                    property['modemPath'] = modemPath
                    _contactClicked(contextMenu.person, contextMenu.clickedItemY, property, type)
                }
            }

            Repeater {
                id: repeater
                model: addressesModel

                MenuItem {
                    text: displayLabel
                    truncationMode: TruncationMode.Fade
                    onClicked: {
                        if (type == 'phoneNumber' && promptSimSelection) {
                            contextMenu.property = property
                            contextMenu.type = type
                            simPicker.active = true
                        } else {
                            _contactClicked(contextMenu.person, contextMenu.clickedItemY, property, type)
                        }
                    }
                }
            }
        }
    }
}
