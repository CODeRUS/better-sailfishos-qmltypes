pragma Singleton
import QtQuick 2.6
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0

QtObject {
    id: root

    property var _unfilteredModel
    property int _deletingContactId: -1

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
}
