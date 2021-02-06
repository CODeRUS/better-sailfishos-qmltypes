/*
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
*/

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import Sailfish.Telephony 1.0
import org.nemomobile.contacts 1.0

Page {
    id: root

    property var aggregateContact
    property var peopleModel
    property bool autoSelect: true
    property var _autoSelectedId

    signal constituentClicked(var constituentId)

    function _reload(contactIds) {
        if (autoSelect && contactIds.length === 1) {
            _autoSelectedId = contactIds[0]
            if (status === PageStatus.Active) {
                delayedConstituentClicked.start()
            }
            return
        }

        constituentModel.clear()
        for (var i = 0; i < contactIds.length; ++i) {
            var p = peopleModel.personById(contactIds[i])
            if (p == null) {
                console.warn("Cannot load person for id:", contactIds[i])
                continue
            }
            constituentModel.append({"person": p})
        }

        busyLabel.running = false
    }

    onStatusChanged: {
        if (status === PageStatus.Active && _autoSelectedId != null) {
            delayedConstituentClicked.start()
        }
    }

    Timer {
        id: delayedConstituentClicked

        interval: 0
        onTriggered: {
            if (_autoSelectedId != null) {
                constituentClicked(_autoSelectedId)
                _autoSelectedId = null
            }
        }
    }

    Component.onCompleted: {
        constituentFetcher.target = aggregateContact
        aggregateContact.fetchConstituents()
    }

    Connections {
        id: constituentFetcher

        target: null
        onConstituentsChanged: {
            _reload(target.constituents)
            target = null
        }
    }

    BusyLabel {
        id: busyLabel

        running: true
    }

    ListModel {
        id: constituentModel
    }

    SilicaListView {
        anchors.fill: parent
        opacity: 1 - busyLabel.opacity
        model: constituentModel

        header: PageHeader {
            visible: !busyLabel.running
            //% "Select contact"
            title: qsTrId("components_contacts-la-select_contact")
        }

        delegate: BackgroundItem {
            id: constituentDelegate

            height: Theme.itemSizeMedium

            // Only allow editable contacts to be picked
            enabled: ContactsUtil.isWritableContact(model.person)

            onClicked: {
                root.constituentClicked(model.person.id)
            }

            ContactAddressBookItem {
                contactPrimaryName: model.person.primaryName
                contactSecondaryName: model.person.secondaryName
                addressBook: model.person.addressBook
                simManager: _simManager
                enabled: constituentDelegate.enabled
            }
        }
    }

    SimManager {
        id: _simManager
    }
}
