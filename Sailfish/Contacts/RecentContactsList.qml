import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import Sailfish.Telephony 1.0
import org.nemomobile.contacts 1.0
import org.nemomobile.commhistory 1.0
import "common/common.js" as ContactsUtils

ListView {
    id: root

    property PeopleModel contactsModel
    property var selectionModel
    property int actionType: Telephony.Call
    property int requiredProperty: PeopleModel.NoPropertyRequired
    property int eventCategoryMask: CommHistory.AnyCategory
    property Component contextMenuComponent
    property bool ready: recentContactsModel.resolved

    property bool _animationEnabled: recentContactsModel.resolved

    signal contactPressed()

    Component.onCompleted: recentContactsModel.getEvents()

    width: parent.width

    // Until the recent model is resolved, assume we will reach the limit of items
    height: recentContactsModel.resolved ? contentHeight : recentContactsModel.limit * Theme.itemSizeSmall
    Behavior on height {
        enabled: root._animationEnabled
        NumberAnimation {
            duration: 150
            easing.type: Easing.InOutQuad
        }
    }

    model: recentContactsModel
    interactive: false

    CommRecentContactsModel {
        id: recentContactsModel
        limit: 10
        requiredProperty: root.requiredProperty
        eventCategoryMask: root.eventCategoryMask
        excludeFavorites: true

        property bool resolved
        function checkResolved() {
            if (ready && !resolving) {
                resolved = true
            }
        }

        onReadyChanged: checkResolved()
        onResolvingChanged: checkResolved()
    }

    // This list view should not move to accomodate the context menu
    property int __silica_hidden_flickable

    delegate: ContactBrowserItem {
        id: contactItem

        width: root.width
        menu: root.contextMenuComponent

        actionType: root.actionType
        contactId: eventPerson.id
        peopleModel: contactsModel

        selectionModel: root.selectionModel

        firstText: eventPerson.primaryName
        secondText: eventPerson.secondaryName
        iconSource: isMessage ? "image://theme/icon-launcher-messaging" : "image://theme/icon-launcher-phone"
        presenceState: eventPerson.globalPresenceState

        Binding {
            when: contactItem.highlighted
            target: root
            property: '_animationEnabled'
            value: false
        }

        property bool isPhone: model.localUid.indexOf('/ring/tel/') >= 0
        property bool isMessage: (model.eventType != CommCallModel.CallEvent) && (model.eventType != CommCallModel.VoicemailEvent)

        property Person eventPerson: Person {
            firstName: ' ' // Non-empty initial string to suppress 'Unnamed'

            Component.onCompleted: {
                if (isPhone) {
                    phoneDetails = [{
                        'number': model.remoteUid,
                        'type': Person.PhoneNumberType,
                        'index': -1
                    }]
                } else {
                    accountDetails = [{
                        'accountPath': model.localUid,
                        'accountUri': model.remoteUid,
                        'type': Person.OnlineAccountType,
                        'index': -1
                    }]
                }
            }
        }

        visible: contentHeight > 0
        contentHeight: {
            if (root.requiredProperty != PeopleModel.NoPropertyRequired) {
                var selectableProperties = getSelectableProperties()
                if (selectableProperties == undefined || !(selectableProperties.length > 0)) {
                    // If this item is not currently selectable, it should have no height
                    return 0
                }
            }
            return Theme.itemSizeSmall
        }

        function getPerson() {
            if (eventPerson.id) {
                return contactsModel.personById(eventPerson.id)
            }
            return eventPerson
        }
        function getSelectableProperties() {
            if (root.requiredProperty != PeopleModel.NoPropertyRequired) {
                // Ensure the import is initialized
                ContactsUtils.init(Person)
                return ContactsUtils.selectableProperties(eventPerson, root.requiredProperty, Person)
            }
            return undefined
        }

        onPressed: root.contactPressed()

        Component.onCompleted: {
            if (isPhone) {
                eventPerson.resolvePhoneNumber(model.remoteUid, false)
            } else {
                eventPerson.resolveOnlineAccount(model.localUid, model.remoteUid, false)
            }
        }
    }
}
