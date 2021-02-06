/*
 * Copyright (c) 2013 - 2019 Jolla Pty Ltd.
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
*/

pragma Singleton
import QtQuick 2.6
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0

QtObject {
    id: root

    property var _unfilteredModel
    property int _deletingContactId: -1
    property var _constituentFetchers: []

    function unfilteredModel() {
        if (_unfilteredModel == null) {
            _unfilteredModel = _unfilteredModelComponent.createObject(root)
        }
        return _unfilteredModel
    }

    property Component _unfilteredModelComponent: Component {
        PeopleModel {
            filterType: PeopleModel.FilterAll

            // Can't make the object read-only, so discourage changes that result in model filtering.
            onFilterTypeChanged: console.log("ContactModelCache.unfilteredModel() should not be filtered! Create another PeopleModel instead.")
            onFilterPatternChanged: console.log("ContactModelCache.unfilteredModel() should not be filtered! Create another PeopleModel instead.")
            onRequiredPropertyChanged: console.log("ContactModelCache.unfilteredModel() should not have requiredProperty set! Create another PeopleModel instead.")
            onSearchablePropertyChanged: console.log("ContactModelCache.unfilteredModel() should not have searchableProperty set! Create another PeopleModel instead.")
        }
    }

    function deleteContact(contact) {
        if (contact.addressBook.isAggregate) {
            var fetcher = _constituentFetchAndDeleteComponent.createObject(
                        root, { "target": contact })
            _constituentFetchers.push(fetcher)
            contact.fetchConstituents()
        } else if (!contact.addressBook.readOnly) {
            unfilteredModel().removePerson(contact)
        } else {
            console.warn("Ignoring request to delete read-only, non-aggregate contact:",
                         contact.id, contact.displayLabel)
        }
    }

    function _deleteConstituents(constituents) {
        var people = []
        for (var i = 0; i < constituents.length; ++i) {
            var person = unfilteredModel().personById(constituents[i])
            if (!person.addressBook.isReadOnly) {
                people.push(person)
            }
        }
        if (people.length > 0) {
            unfilteredModel().removePeople(people)
        } else {
            console.warn("All contacts belong to read-only address books, so will not be deleted")
        }
    }

    property var _constituentFetchAndDeleteComponent: Component {
        Connections {
            id: constituentFetchAndDelete

            onConstituentsChanged: {
                _deleteConstituents(target.constituents)
                for (var i = 0; i < root._constituentFetchers.length; ++i) {
                    if (root._constituentFetchers[i] === constituentFetchAndDelete) {
                        root._constituentFetchers.splice(i, 1)
                        break
                    }
                }
                destroy()
            }
        }
    }
}
