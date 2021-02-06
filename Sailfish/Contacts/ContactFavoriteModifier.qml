/*
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
*/

import QtQuick 2.6
import Sailfish.Silica 1.0

QtObject {
    id: root

    property var peopleModel
    readonly property bool lastStatus: _pendingStatus
    readonly property bool lastStatusValid: _wasSet

    property bool _pendingStatus
    property bool _wasSet

    function setFavoriteStatus(contact, favorite) {
        _pendingStatus = favorite
        _wasSet = true

        if (_conn.target != null) {
            return
        }

        if (!contact.addressBook.isAggregate) {
            contact.favorite = !contact.favorite
            peopleModel.savePerson(contact)
            return
        }

        // Ensure latest constituent data is loaded before editing
        _conn.target = contact
        contact.fetchConstituents()
    }

    function _applyFavoriteStatus(constituents) {
        var people = []
        for (var i = 0; i < constituents.length; ++i) {
            var person = peopleModel.personById(constituents[i])
            person.favorite = _pendingStatus
            people.push(person)
        }
        if (!peopleModel.savePeople(people)) {
            console.warn("Unable to save favorite status to contacts:", constituents)
        }
    }

    property var _conn: Connections {
        target: null
        onConstituentsChanged: {
            _applyFavoriteStatus(target.constituents)
            target = null
        }
    }
}
