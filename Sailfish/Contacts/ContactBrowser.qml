import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0
import "contactcard/ContactsDBusService.js" as ContactsService
import "common/common.js" as ContactsUtils

SilicaFlickable {
    id: root

    property bool searchEnabled
    property string searchPattern: contactSearchField.text
                                           //: Contacts list
                                           //% "Search people"
    property string searchPlaceholderText: qsTrId("components_contacts-ph-search_people")

    property bool contactsSelectable
    property QtObject selectedContacts: selectedContactsModel
    property alias showSearchPatternAsNewContact: searchView.showSearchPatternAsNewContact

    property bool handleEdit: true
    property bool deleteOnlyContextMenu
    property alias placeholderText: placeholder.text
    property alias topContent: topContentPlaceholder.data
    property alias hasSearchFocus: searchView.hasSearchFocus

    property bool showRecentContactList: true

    // If requiredProperty is 0, selections correspond to contacts.  If requiredProperty
    // is specified, the browser requires the selection of a specific property within a contact.
    // Supported properties is a combination of: PeopleModel.EmailAddressRequired, AccountUriRequired, PhoneNumberRequired
    property int requiredProperty: PeopleModel.NoPropertyRequired
    property int searchableProperty

    property bool uniformSelectionTypes: true
    property int _filterProperty: requiredProperty

    property bool _menuOpen: pullDownMenu && pullDownMenu.active || pushUpMenu && pushUpMenu.active

    function findPage(item) {
        var parentItem = item.parent
        while (parentItem) {
            if (parentItem.hasOwnProperty('__silica_page')) {
                return parentItem
            }
            parentItem = parentItem.parent
        }
        return null
    }

    property Page _page: findPage(root)
    property bool _isLandscape: _page && _page == pageStack.currentPage && _page.isLandscape
    property bool _isDialog: _page && _page == pageStack.currentPage && _page.hasOwnProperty('__silica_dialog')

    property int _pageStatus: _page ? _page.status : PageStatus.Inactive
    on_PageStatusChanged: {
        if (_pageStatus == PageStatus.Activating) {
            // Reset any previous changes to the filter
            _filterProperty = requiredProperty
        }
    }

    // In landscape mode, the search field is positioned inside the page header, with an offset from the left edge
    property real _leftMarginOffset: _isLandscape && pageStack._pageStackIndicator && pageStack._pageStackIndicator.leftWidth ? (pageStack._pageStackIndicator.leftWidth + Theme.paddingMedium) : 0

    property alias _searchFiltered: searchView.filtered

    property ListModel selectedContactsModel: ListModel {
        function addContact(contact, displayInSelectionList, formattedNameText, property, propertyType) {
            append({"person": contact,
                    "displayInSelectionList": displayInSelectionList,
                    "formattedNameText": formattedNameText,
                    "property": property,
                    "propertyType": propertyType})

            if (count == 1 && propertyType != undefined) {
                if (propertyType == 'accountUri' && root._isDialog) {
                    // No further selections are currently allowed - accept the dialog
                    root._page.accept()
                } else if (root.uniformSelectionTypes) {
                    // Further selections must be of the same type
                    if (propertyType == 'phoneNumber') {
                        // Animate the favorites bar resize if the filter change causes a height reduction
                        favoritesBar.heightAnimationEnabled = true
                        root._filterProperty = PeopleModel.PhoneNumberRequired
                    } else if (propertyType == 'emailAddress') {
                        favoritesBar.heightAnimationEnabled = true
                        root._filterProperty = PeopleModel.EmailAddressRequired
                    } else if (propertyType == 'accountUri') {
                        favoritesBar.heightAnimationEnabled = true
                        root._filterProperty = PeopleModel.AccountUriRequired
                    }
                }
            }
        }

        function removeContactAt(index) {
            remove(index)

            if (count == 0 && root.uniformSelectionTypes) {
                favoritesBar.heightAnimationEnabled = true
                root._filterProperty = root.requiredProperty
            }
        }

        function findContact(contact) {
            return findContactId(contact.id)
        }

        function findContactId(id) {
            for (var i = 0; i < count; i++) {
                if (get(i).person.id === id)
                    return i
            }
            return -1
        }

        function findDummyContact(name) {
            for (var i = 0; i < count; i++) {
                if (get(i).person.firstName === name)
                    return i
            }
            return -1
        }
    }

    property QtObject selectionModel: contactsSelectable ? selectedContactsModel : null

    /*
       We create multiple models deliberately:
        - one will change its search pattern dynamically, and is used for the search results.
        - one will consist only of favorites, and is used for the favorites bar.
        - one will consist of all contacts
       We don't simply use one model and pass it around, as that
       will cause delegates of the list view to be recreated, and
       possible save failures when editing contacts.
     */

    property PeopleModel _dynamicContactsModel: PeopleModel {
        filterType: PeopleModel.FilterNone
        filterPattern: root.searchPattern
        requiredProperty: root._filterProperty
        searchableProperty: root.searchableProperty
    }

    property PeopleModel favoriteContactsModel: PeopleModel {
        filterType: PeopleModel.FilterFavorites
        requiredProperty: root._filterProperty
    }

    property PeopleModel allContactsModel: PeopleModel {
        filterType: PeopleModel.FilterAll
        requiredProperty: root._filterProperty
    }

    property Item _lastClickedContact
    property real _contentYBeforeGroupOpen: -1
    property real _newContentY: 0
    property real _searchListSpace: Screen.height - topContentArea.height

    onSearchEnabledChanged: {
        // Activate/deactivate the VKB by changing focus target
        (searchEnabled ? contactSearchField : root).focus = true
    }
    onAtYBeginningChanged: {
        if ((atYBeginning && _searchFiltered && (searchView.height > _searchListSpace)) ||
            (!atYBeginning && contactSearchField.focus)) {
            (atYBeginning ? contactSearchField : root).focus = true
        }
    }

    // Call UI needs position of the contact delegate
    signal contactClicked(variant contact, variant clickedItemY, variant property, string propertyType)
    signal editRequested(variant contact)

    function forceSearchFocus() {
        searchView.setFocus(true)
    }

    function removeLastClickedContact(contactIdCheck) {
        if (_lastClickedContact !== null) {
            _lastClickedContact.remove(contactIdCheck)
        }
        _lastClickedContact = null
    }

    function _closeVKB() {
        root.focus = true
    }

    function _contactItemClicked(item, itemY, contact, property, propertyType) {
        _lastClickedContact = item
        contactClicked(_ensureComplete(contact), itemY, property, propertyType)
    }

    function _editContact(person) {
        if (handleEdit) {
            ContactsService.editContact(person.id)
        } else {
            editRequested(_ensureComplete(person))
        }
    }

    function _ensureComplete(contact) {
        if (contact.id) {
            // Ensure that we use the cache's canonical version of this contact
            contact = allContactsModel.personById(contact.id)
        }
        if (!contact.complete) {
            contact.ensureComplete()
        }
        return contact
    }

    function _animateContentY(newValue, duration, easing) {
        _newContentY = newValue
        contentYAnimation.duration = duration
        contentYAnimation.easing.type = easing
        contentYAnimation.start()
    }

    width: parent ? parent.width : Screen.width
    height: parent ? parent.height : Screen.height
    contentHeight: Math.max(1, contentColumn.height)

    onFlickStarted: _contentYBeforeGroupOpen = -1

    VerticalScrollDecorator {}

    ViewPlaceholder {
        id: placeholder
        //: Displayed when there are no contacts
        //%  "No people"
        text: qsTrId("components_contacts-la-no_people")
        enabled: allContactsModel.populated && allContactsModel.count == 0
    }

    NumberAnimation {
        id: contentYAnimation
        target: root
        property: "contentY"
        to: root._newContentY
    }

    Column {
        id: contentColumn

        width: parent.width
        visible: !placeholder.enabled

        Item {
            id: topContentArea
            width: parent.width
            height: topContentPlaceholder.height + searchFieldPlaceholder.height

            function findExtraContent() {
                for (var i = 0; i < topContentPlaceholder.data.length; ++i) {
                    if (topContentPlaceholder.data[i].hasOwnProperty('extraContent')) {
                        return topContentPlaceholder.data[i].extraContent
                    }
                }
                return null
            }

            property Item extraContent: findExtraContent()
            property bool embedSearchField: root._isLandscape && extraContent != null

            Item {
                id: topContentPlaceholder
                height: childrenRect.height
                width: parent.width
            }
            Item {
                id: searchFieldPlaceholder
                width: parent.width
                y: topContentPlaceholder.y + topContentPlaceholder.height

                height: topContentArea.embedSearchField || !contactSearchField.enabled ? 0 : contactSearchField.height
                Behavior on height {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            SearchField {
                id: contactSearchField

                parent: topContentArea.embedSearchField ? topContentArea.extraContent : searchFieldPlaceholder
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                }

                autoScrollEnabled: false
                placeholderText: root.searchPlaceholderText

                // avoid removing focus whenever a contact is added to the selection list
                focusOutBehavior: FocusBehavior.KeepFocus

                enabled: root.searchEnabled
                onEnabledChanged: {
                    if (!enabled) {
                        text = ''
                    }
                }

                visible: opacity > 0
                opacity: root.searchEnabled ? 1 : 0
                Behavior on opacity {
                    FadeAnimation {
                        duration: 150
                    }
                }
            }
        }

        ContactSearchView {
            id: searchView

            searchField: contactSearchField
            selectionModel: root.selectionModel
            resultsModel: _dynamicContactsModel

            active: searchEnabled
            leftMarginOffset: root._leftMarginOffset

            delegate: ContactBrowserItem {
                width: root.width
                menu: contactContextMenuComponent
                leftMarginOffset: root._leftMarginOffset

                contactId: model.contactId
                selectionModel: root.selectionModel

                firstText: model.primaryName
                secondText: model.secondaryName
                presenceState: model.globalPresenceState

                searchString: root.searchPattern

                onPressed: _closeVKB()

                function getPerson() { return model.person }
                function getSelectableProperties() {
                    // Ensure the import is initialized
                    ContactsUtils.init(Person)
                    return ContactsUtils.selectableProperties(model, root._filterProperty, Person)
                }
            }

            onActiveChanged: {
                if (active) {
                    _dynamicContactsModel.prepareSearchFilters()
                }
            }

            onDummyContactPressed: _closeVKB()
            onDummyContactClicked: {
                personData.firstName = searchPattern
                personData.phoneDetails = [{
                    'number': searchPattern,
                    'type': Person.PhoneNumberType,
                    'index': -1
                }]
                if (root.contactsSelectable) {
                    var selectionIndex = selectionModel.findDummyContact(searchPattern)
                    if (selectionIndex < 0) {
                        selectionModel.addContact(personData, true, searchPattern, searchPattern)
                        searchView.searchPattern = ""
                    }
                }
                _contactItemClicked(null, undefined, personData, searchPattern, 'phoneNumber')
            }
        }

        FavoritesBar {
            id: favoritesBar

            visible: !_searchFiltered
            favoritesModel: root.favoriteContactsModel
            selectionModel: root.selectionModel
            requiredProperty: root._filterProperty
            contextMenuComponent: contactContextMenuComponent

            enabled: !_searchFiltered && favoritesModel.populated && (favoritesModel.count > 0)
            opacity: enabled ? 1 : 0
            Behavior on opacity { FadeAnimation {} }

            onContactPressed: _closeVKB()
            onContactClicked: _contactItemClicked(contactItem, undefined, contact, property, propertyType)
        }

        Component {
            id: contactList

            Column {
                width: contentColumn.width

                SectionHeader {
                    visible: !_searchFiltered && recentContactsList.count > 0
                    //% "Recent"
                    text: qsTrId("components_contacts-he-recent")
                    opacity: recentContactsList.opacity
                }

                Item {
                    height: recentContactsList.height
                    width: parent.width

                    RecentContactsList {
                        id: recentContactsList
                        visible: !_searchFiltered
                        contactsModel: allContactsModel
                        selectionModel: root.selectionModel
                        requiredProperty: root._filterProperty
                        contextMenuComponent: contactContextMenuComponent

                        enabled: !_searchFiltered && favoritesModel.populated
                        opacity: enabled ? 1 : 0
                        Behavior on opacity { FadeAnimation {} }

                        onContactPressed: _closeVKB()
                    }

                    BusyIndicator {
                        anchors {
                            top: parent.top
                            topMargin: Theme.itemSizeExtraLarge
                            horizontalCenter: parent.horizontalCenter
                        }
                        size: BusyIndicatorSize.Large
                        // starting from favoritesBar.enabled avoids a
                        // visual jump of the spinner when the favoritesBar
                        // starts taking up space.
                        running: favoritesBar.enabled
                            && !recentContactsList.ready
                    }
                }
            }
        }

        Loader {
            id: listLoader
            sourceComponent: root.showRecentContactList ? contactList : undefined
        }

        ContactNameGroupView {
            id: nameGroupView
            visible: !_searchFiltered
            width: parent.width
            requiredProperty: root._filterProperty

            enabled: !_searchFiltered && root.favoriteContactsModel.populated
            opacity: enabled ? 1 : 0
            Behavior on opacity { FadeAnimation {} }

            delegate: ContactBrowserItem {
                width: root.width
                menu: contactContextMenuComponent

                contactId: model.contactId
                selectionModel: root.selectionModel

                firstText: model.primaryName
                secondText: model.secondaryName
                presenceState: model.globalPresenceState

                function getPerson() { return model.person }
                function getSelectableProperties() {
                    // Ensure the import is initialized
                    ContactsUtils.init(Person)
                    return ContactsUtils.selectableProperties(model, root._filterProperty, Person)
                }
            }

            onNameGroupPressed: _closeVKB()
            onActivated: {
                // If height is reduced, allow the exterior flickable to reposition itself
                if (newViewHeight > nameGroupView.height) {
                    // Where should the list be positioned to show as much of the list as possible
                    // (but also show one row beyond the list if possible)
                    var maxVisiblePosition = nameGroupView.y + viewSectionY + newListHeight + rowHeight - root.height

                    // Ensure up to two rows of group elements to show at the top
                    var maxAllowedPosition = nameGroupView.y + Math.max(viewSectionY - (2 * rowHeight), 0)

                    // Don't position beyond the end of the flickable
                    var totalContentHeight = contentColumn.height + (newViewHeight - nameGroupView.height)
                    var maxContentY = root.originY + totalContentHeight - root.height

                    var newContentY = Math.max(Math.min(Math.min(maxVisiblePosition, maxAllowedPosition), maxContentY), 0)
                    if (newContentY > root.contentY) {
                        if (root._contentYBeforeGroupOpen < 0) {
                            root._contentYBeforeGroupOpen = root.contentY
                        }
                        root._animateContentY(newContentY, heightAnimationDuration, heightAnimationEasing)
                    }
                }
            }
            onDeactivated: {
                if (root._contentYBeforeGroupOpen >= 0) {
                    root._animateContentY(root._contentYBeforeGroupOpen, heightAnimationDuration, heightAnimationEasing)
                    root._contentYBeforeGroupOpen = -1
                }
            }
        }
    }

    Component {
        id: contactContextMenuComponent

        ContextMenu {
            id: menu

            property QtObject person
            property bool favorite

            function _addToFavorites() {
                if (person.complete) {
                    person.completeChanged.disconnect(_addToFavorites)
                    person.favorite = true
                    allContactsModel.savePerson(person)
                } else {
                    person.completeChanged.connect(_addToFavorites)
                }
            }

            function _removeFromFavorites() {
                if (person.complete) {
                    person.completeChanged.disconnect(_removeFromFavorites)
                    person.favorite = false
                    allContactsModel.savePerson(person)
                } else {
                    person.completeChanged.connect(_removeFromFavorites)
                }
            }

            onActiveChanged: {
                if (active) {
                    favorite = person.favorite
                }
            }

            MenuItem {
                //: Edit contact, from list
                //% "Edit"
                text: qsTrId("components_contacts-me-edit_contact")
                onClicked: root._editContact(person)
                visible: !root.deleteOnlyContextMenu
            }
            MenuItem {
                text: menu.favorite
                      //: Set contact as not favorite
                      //% "Remove from favorites"
                    ? qsTrId("components_contacts-me-remove_contact_from_favorites")
                      //: Set contact as favorite
                      //% "Add to favorites"
                    : qsTrId("components_contacts-me-add_contact_to_favorites")
                visible: !root.deleteOnlyContextMenu
                onClicked: {
                    if (menu.favorite) {
                        menu._removeFromFavorites()
                    } else {
                        menu._addToFavorites()
                    }
                }
            }
            MenuItem {
                //: Delete contact, from list
                //% "Delete"
                text: qsTrId("components_contacts-me-delete")
                onClicked: menu.parent.remove()
            }
        }
    }
}
