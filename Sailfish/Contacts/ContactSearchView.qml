import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0

Item {
    id: root

    property bool active
    property string searchPattern: searchField.text
    property bool showSearchPatternAsNewContact
    property alias resultsModel: searchResultsList.model

    property SearchField searchField
    property QtObject selectionModel
    property Component delegate

    property bool hasSearchFocus: searchField.activeFocus
    property bool filtered: active && searchPattern != ''

    property real leftMarginOffset

    signal contactClicked(variant contact, variant clickedItemY, variant property)
    signal dummyContactClicked(variant personData)
    signal dummyContactPressed(variant personData)

    function setFocus(hasFocus) {
        if (hasFocus) {
            // need to forceActiveFocus() when returning to the main view page in contacts -
            // maybe a QtQuick1 bug?
            searchField.forceActiveFocus()
        } else {
            root.focus = true
        }
    }

    width: parent.width
    height: 0
    opacity: 0

    states: State {
        name: "active"
        when: root.active
        PropertyChanges {
            target: root
            height: contentColumn.height
            opacity: 1.0
        }
    }

    transitions: Transition {
        NumberAnimation { properties: "height, opacity"; duration: 250 }
    }

    Column {
        id: contentColumn

        width: root.width

        ContactItem {
            id: dummyContact

            width: root.width
            height: root.showSearchPatternAsNewContact && root.filtered ? Theme.itemSizeSmall : 0
            visible: height > 0

            firstText: searchPattern
            presenceState: Person.PresenceUnknown
            searchString: searchPattern
            leftMarginOffset: root.leftMarginOffset

            property Person person: Person {
                firstName: searchPattern
                phoneDetails: [{
                    'number': firstName,
                    'type': Person.PhoneNumberType,
                    'index': -1
                }]
            }

            onPressed: root.dummyContactPressed(person)
            onClicked: root.dummyContactClicked(person)
        }

        ColumnView {
            id: searchResultsList

            width: parent.width
            visible: root.filtered

            itemHeight: Theme.itemSizeSmall
            delegate: root.delegate
        }
    }
}
