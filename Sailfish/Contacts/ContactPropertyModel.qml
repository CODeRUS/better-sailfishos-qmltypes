import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0 as Contacts
import org.nemomobile.contacts 1.0

ListModel {
    property int requiredProperty

    property QtObject contact
    onContactChanged: setProperties(getSelectableProperties())

    property var _emailUpdater: Connections {
        target: requiredProperty & PeopleModel.EmailAddressRequired ? contact : null
        onEmailDetailsChanged: setProperties(getSelectableProperties())
    }

    property var _phoneUpdater: Connections {
        target: requiredProperty & PeopleModel.PhoneNumberRequired ? contact : null
        onPhoneDetailsChanged: setProperties(getSelectableProperties())
    }

    property var _accountUpdater: Connections {
        target: requiredProperty & PeopleModel.AccountUriRequired ? contact : null
        onAccountDetailsChanged: setProperties(getSelectableProperties())
    }

    function getSelectableProperties() {
        return ContactsUtil.selectableProperties(contact, requiredProperty, Person)
    }

    function setProperties(properties) {
        clear()
        if (properties) {
            for (var i = 0; i < properties.length; i++) {
                append({
                    "displayLabel": properties[i].displayLabel,
                    "property": properties[i].property,
                    "propertyType": properties[i].propertyType
                })
            }
        }
    }

    Component.onCompleted: {
        if (contact) {
            setProperties(getSelectableProperties())
        }
    }
}
