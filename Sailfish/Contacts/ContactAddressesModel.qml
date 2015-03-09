import QtQuick 2.0
import org.nemomobile.contacts 1.0
import "common/common.js" as ContactsUtils

ListModel {
    id: addressesModel

    property int requiredProperty

    property QtObject contact
    onContactChanged: setAddresses(getSelectableProperties())

    function getSelectableProperties() {
        // Ensure the import is initialized
        ContactsUtils.init(Person)
        return ContactsUtils.selectableProperties(contact, requiredProperty, Person)
    }

    function setAddresses(addresses) {
        clear()
        if (addresses) {
            for (var i = 0; i < addresses.length; i++) {
                append({
                    "displayLabel": addresses[i].displayLabel,
                    "property": addresses[i].property,
                    "type": addresses[i].propertyType
                })
            }
        }
    }
}
