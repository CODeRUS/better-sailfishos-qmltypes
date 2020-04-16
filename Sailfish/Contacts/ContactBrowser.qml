import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0 as SailfishContacts
import org.nemomobile.commhistory 1.0
import org.nemomobile.contacts 1.0

Item {
    id: root

    //--- Searching and selection properties ---

    // Whether the search bar is shown
    property bool searchActive

    // Whether the search bar can be hidden by the user
    property bool canHideSearchField

    // Whether contacts can be highlighted and added to the selection model
    property bool canSelect

    // Filter to apply to the recent contacts list
    property alias recentContactsCategoryMask: _recentContactsModel.eventCategoryMask

    // If set, then only contacts with this property can be selected or found in a search.
    // Supported properties is a combination of: PeopleModel.EmailAddressRequired, AccountUriRequired, PhoneNumberRequired
    property int requiredContactProperty: PeopleModel.NoPropertyRequired

    // If true, once a contact is selected, the browser will only show other contacts that also
    // have the same type.
    property bool uniformSelectionTypes: true

    // Properties to be made searchable as part of a search query
    property int searchableContactProperty

    // Model of the selected contacts
    readonly property alias selectedContacts: contactSelectionModel


    //--- UI configuration: ---

    // Reference to the main flickable item that presents the list of contacts.
    readonly property alias contactView: mainContactsList

    // Page or dialog header component
    property Component pageHeader

    // Page or dialog header object, instantiated from the component
    readonly property var pageHeaderItem: mainContactsList.headerItem ? mainContactsList.headerItem.pageHeaderLoader.item : null

    // Margin above the view (defaults to DialogHeader height if inside a dialog)
    property real topMargin: _dialogHeaderHeight

    // Full-page placeholder text to be shown when no contacts are available
    //: Displayed when there are no contacts
    //%  "No people"
    property string placeholderText: qsTrId("components_contacts-la-no_people")

    // Placeholder component shown when no contacts are available. Override to customize shown placeholder labels and actions.
    property alias placeholder: placeholder.sourceComponent

    // Configuration of the symbol scrollbar.
    property alias symbolScroller: symbolScrollConfiguration
    SymbolScrollConfiguration {
        id: symbolScrollConfiguration
        width: symbolScrollBar.width

        // The space between the top of the ContactBrowser and the scrollbar.
        // Note this is applied in addition to the ContactBrowser topMargin.
        // The default is equivalent to a default page header height.
        topMargin: _isLandscape
                   ? (_isDialog ? Theme.paddingLarge : Theme.itemSizeSmall)
                   : (_isDialog ? Theme.paddingLarge : Theme.itemSizeLarge)

        // The space between the bottom of the ContactBrowser and the scrollbar.
        bottomMargin: _isLandscape
                      ? Theme.paddingLarge
                      : Theme.itemSizeLarge
    }

    //--- Other public properties: ---

    /*
       We create multiple models deliberately:
        - one will change its search pattern dynamically, and is used for the search results.
        - one will consist only of favorites, and is used for the favorites bar.
        - one will consist of all contacts
       We don't simply use one model and pass it around, as that
       will cause delegates of the list view to be recreated, and
       possible save failures when editing contacts.
     */
    property var _dynamicContactsModel: PeopleModel {
        filterType: PeopleModel.FilterNone
        filterPattern: root._searchPattern
        requiredProperty: root._filterProperty
        searchableProperty: root.searchableContactProperty
    }
    property var favoriteContactsModel: PeopleModel {
        filterType: PeopleModel.FilterFavorites
        requiredProperty: root._filterProperty
    }
    property var allContactsModel: PeopleModel {
        filterType: PeopleModel.FilterAll
        requiredProperty: root._filterProperty
    }


    //--- signals: ---

    signal contactClicked(var contact)
    signal contactPressAndHold(var contact)


    //--- functions: ---

    function forceSearchFocus() {
        mainContactsList.headerItem.forceSearchFocus()
    }

    function resetScrollPosition() {
        mainContactsList.positionViewAtBeginning()
        symbolScrollBar.resetScrollPosition()
    }

    // Opens a menu to allow the user to select from a list of property values for the last contact
    // that was clicked (or pressed+held) in the list. E.g. if requiredProperty==PeopleModel.PhoneNumberRequired,
    // then a list of the contact's phone numbers is displayed. If a context menu is already
    // open within the contact list, the new menu will be embedded within that instead of opening a
    // separate menu.
    //
    // When the user makes the selection, propertySelectedCallback is called with these arguments:
    //  - 'contact' - the SeasidePerson* object
    //  - 'propertyData' - a JavaScript object describing the selected property. E.g. if a phone
    //    number is selected, this map contains {"property": { "number": <selected-phone-number> }}.
    //    See common.js selectableProperties() for the possible property values.
    //  - 'contextMenu' - the context menu showing the list of properties, if applicable
    //  - 'propertyPicker' the property picker object
    //
    // If the contact only has one property of the required type, no menu is shown, and the callback
    // function is invoked immediately with that single property value. If the contact has no
    // properties of the required type, propertySelectedCallback is invoked immediately with an
    // empty propertyData map.
    //
    // The contactId parameter ensures that the menu is shown for the intended contact - i.e. the
    // last clicked/held contact. If it does not match the last clicked/held contact, this does nothing.
    //
    // This does nothing if requiredProperty==PeopleModel.NoPropertyRequired.
    //
    function selectContactProperty(contactId, requiredProperty, propertySelectedCallback) {
        if (!_verifyActiveDelegateContact(contactId)) {
            return
        }
        if (requiredProperty === PeopleModel.NoPropertyRequired) {
            console.warn("Cannot open property picker, requiredProperty==NoPropertyRequired so no properties are available for selection")
            return
        }
        if (!propertySelectedCallback) {
            console.warn("Cannot open property picker, no selection callback function provided")
            return
        }
        if (!_activeDelegate.propertyPicker) {
            var props = {
                "silicaListView": mainContactsList,
                "contactDelegateItem": _activeDelegate,
                "contact": _activeDelegate.personObject(),
                "requiredProperty": requiredProperty,
                "propertySelectedCallback": propertySelectedCallback
            }
            var component = Qt.createComponent("ContactPropertyPicker.qml")
            if (component.status === Component.Error) {
                console.log("Unable to load component", component.url, component.errorString())
                return
            }
            _activeDelegate.propertyPicker = component.createObject(_activeDelegate, props)
        }
        _activeDelegate.propertyPicker.openMenu()
    }

    // Opens a context menu for the last contact that was clicked (or pressed+held) in the list.
    // Or, if selectContactProperty() has opened a page with a list of contact properties for
    // the matching contact, and that page is still active, the context menu is opened for the
    // last selected property.
    //
    // The given menu must be a Component.
    //
    // The contactId parameter ensures that the menu is shown for the intended contact - i.e. the
    // last clicked/held contact. If it does not match the last clicked/held contact, this does nothing.
    //
    function openContextMenu(contactId, menu, menuProperties) {
        if (!_verifyActiveDelegateContact(contactId)) {
            return
        }
        if (_activeDelegate.propertyPicker && _activeDelegate.propertyPicker.pickerPageActive) {
            _activeDelegate.propertyPicker.openPickerPageMenu(menu, menuProperties)
        } else {
            _activeDelegate.menu = menu
            _activeDelegate.openMenu(menuProperties)
        }
    }

    //--- Internal properties and functions: ---

    readonly property var _selectionModel: canSelect ? contactSelectionModel : null
    property string _searchPattern
    readonly property bool _searchFiltered: searchActive && _searchPattern.length > 0
    property int _filterProperty: requiredContactProperty
    property var _activeDelegate

    readonly property int _dialogHeaderHeight: (_isDialog && !!mainContactsList.headerItem) ? mainContactsList.headerItem.pageHeaderLoader.height : 0
    readonly property int _sectionHeaderHeight: Theme.itemSizeExtraSmall
    readonly property bool _showInitialContent: favoriteContactsModel.populated
                                                && allContactsModel.populated
                                                && _recentContactsModel.ready

    readonly property real _scrollIgnoredContentHeight: {
        // Ignore heights of search field and context menus so that the scrollbar doesn't
        // appear/disappear depending on whether these are visible.
        return (root._isLandscape ? 0 : mainContactsList.headerItem.searchFieldHeight)
                + (mainContactsList.__silica_contextmenu_instance ? mainContactsList.__silica_contextmenu_instance.height : 0)
    }

    readonly property Page _page: {
        var parentItem = root.parent
        while (parentItem) {
            if (parentItem.hasOwnProperty('__silica_page')) {
                return parentItem
            }
            parentItem = parentItem.parent
        }
        return null
    }
    readonly property bool _isLandscape: _page && _page.isLandscape
    readonly property bool _isDialog: _page && _page.hasOwnProperty('__silica_dialog')
    readonly property int _pageStatus: _page ? _page.status : PageStatus.Inactive
    on_PageStatusChanged: {
        if (_pageStatus === PageStatus.Activating) {
            // Reset any previous changes to the filter
            _filterProperty = root.requiredContactProperty
        }
    }

    // Place any default content inside the flickable to make it easy to e.g. add pulley menus
    default property alias _content: mainContactsList.data

    function _closeVirtualKeyboard() {
        root.focus = true
    }

    // Returns the section header y for an item currently in view.
    function _sectionHeaderY(index) {
        // Find the y of the desired index and return the y of the section header above it.
        var yPos = mainContactsList.contentY
        var nextIndex = -1
        while (nextIndex < index && yPos < mainContactsList.contentY + mainContactsList.height) {
            nextIndex = mainContactsList.indexAt(0, yPos)
            if (nextIndex < index) {
                yPos += Theme.itemSizeSmall
            }
        }
        if (nextIndex === index) {
            var nextItem = mainContactsList.itemAt(0, yPos)
            if (nextItem) {
                return nextItem.mapToItem(mainContactsList.contentItem, 0, -root._sectionHeaderHeight).y
            }
        }
        return null
    }

    function _clampYPos(yPos) {
        return Math.max(mainContactsList.originY, Math.min(yPos, mainContactsList.contentY))
    }

    function _scrollContactsTo(indexOrItem) {
        // Prevent the pulley menu from running its snap-back animations that automatically return
        // the contentY to the flickable start if movement stops within 80px of the start.
        if (mainContactsList.pullDownMenu) {
            mainContactsList.pullDownMenu._stopAnimations()
        }
        if (mainContactsList.pushUpMenu) {
            mainContactsList.pushUpMenu._stopAnimations()
        }

        if (indexOrItem === mainContactsList.headerItem.favoriteContactsSection) {
            mainContactsList.positionViewAtBeginning()
        } else if (indexOrItem === mainContactsList.headerItem.recentContactsSection) {
            mainContactsList.contentY = _favoriteContactsEndY() - root.topMargin
            mainContactsList.returnToBounds()
        } else if (indexOrItem >= 0) {
            // QTBUG-49989: if item is not currently in view, the first call to positionViewAtEnd/Index
            // doesn't quite get the contentY to the correct position, so need to call it twice.
            if (indexOrItem === mainContactsList.count-1) {
                mainContactsList.positionViewAtEnd()
                mainContactsList.positionViewAtEnd()
            } else {
                mainContactsList.positionViewAtIndex(indexOrItem, ListView.Beginning)
                mainContactsList.positionViewAtIndex(indexOrItem, ListView.Beginning)

                // Offset the scroll position by topMargin to ensure the section header is in view.
                if (root.topMargin !== 0) {
                    if (mainContactsList.atYEnd) {
                        // There's less than a screen of content remaining, so scroll down just
                        // enough to put the section header in view, instead of scrolling by
                        // the full topMargin amount.
                        var sectionHeaderY = _sectionHeaderY(indexOrItem)
                        if (sectionHeaderY !== null) {
                            var distanceToTopMarginEnd = (mainContactsList.contentY + root.topMargin) - sectionHeaderY
                            mainContactsList.contentY = _clampYPos(mainContactsList.contentY - distanceToTopMarginEnd)
                            return
                        }
                    }

                    // There's more than a screen of content remaining. Scroll down by the
                    // topMargin amount to put the section header in view.
                    mainContactsList.contentY = _clampYPos(mainContactsList.contentY - root.topMargin)
                }
            }
        }
    }

    function _favoriteContactsEndY() {
        return mainContactsList.originY + mainContactsList.headerItem.favoriteContactsSection.y
                + mainContactsList.headerItem.favoriteContactsSection.height
    }

    function _recentContactsEndY() {
        return mainContactsList.originY + mainContactsList.headerItem.recentContactsSection.y
                + mainContactsList.headerItem.recentContactsSection.height
    }

    // Find the section of the first contact currently seen at the top of the view. If only half of
    // this contact delegate is visible, and it is also the last entry for its section, return the
    // following section instead.
    function _findFirstVisibleSection() {
        if (!mainContactsList.headerItem) {
            return "" // not yet fully loaded.
        }

        var yPos = mainContactsList.contentY + root.topMargin
        var halfDelegateHeight = Theme.itemSizeSmall/2

        // See if the first section is within the header area.
        if (yPos < mainContactsList.originY + mainContactsList.headerItem.height) {
            if (symbolScrollBar.favoriteIconEnabled
                    && yPos < _favoriteContactsEndY() - halfDelegateHeight) {
                return 0
            } else if (symbolScrollBar.recentIconEnabled
                       && yPos < _recentContactsEndY() - halfDelegateHeight) {
                return 1
            } else {
                return displayLabelGroupModel.get(0, PeopleDisplayLabelGroupModel.NameRole)
            }
        }

        // This is a contact in the main list.
        var contactIndex = mainContactsList.indexAt(0, yPos)
        if (contactIndex < 0) {
            // No contact found at the current contentY. This should mean it is a section header,
            // so find the first contact below it.
            contactIndex = mainContactsList.indexAt(0, root._sectionHeaderHeight + yPos)
            if (contactIndex >= 0) {
                return allContactsModel.get(contactIndex, PeopleModel.SectionBucketRole)
            } else {
                console.log("Can't find contact for section at", root._sectionHeaderHeight + yPos)
                return ""
            }
        }

        // If only half of this contact delegate is visible, and it is also the last contact in its
        // section (i.e. the next item is a section header), return the next section instead.
        var nextContactIndex = mainContactsList.indexAt(0, yPos + halfDelegateHeight)
        if (nextContactIndex < 0) {     // -1 means it is a section header
            return allContactsModel.get(contactIndex + 1, PeopleModel.SectionBucketRole)
        }

        return allContactsModel.get(contactIndex, PeopleModel.SectionBucketRole)
    }

    function _resetHighlightedSymbol() {
        if (!_showInitialContent || displayLabelGroupModel.count === 0) {
            return
        }

        // Find the section of the first contact in view, and sync the symbol scrollbar to
        // highlight the corresponding symbol.
        var sectionBucket = _findFirstVisibleSection()
        if (sectionBucket === 0) {
            symbolScrollBar.highlightFavoriteIcon()
        } else if (sectionBucket === 1) {
            symbolScrollBar.highlightRecentIcon()
        } else if (sectionBucket !== "") {
            symbolScrollBar.highlightSymbolIndex(displayLabelGroupModel.indexOf(sectionBucket), sectionBucket)
        }
    }

    function _setMenuOpen(menuOpen, menuItem) {
        symbolScrollBar.enabled = !menuOpen
        if (menuOpen) {
            mainContactsList.__silica_contextmenu_instance = menuItem
        } else if (mainContactsList.__silica_contextmenu_instance === menuItem) {
            mainContactsList.__silica_contextmenu_instance = null
        }
    }

    function _contactClicked(contactDelegateItem, contact) {
        if (!contactDelegateItem) {
            console.log("Contact clicked but no delegate specified!")
            return
        }

        if (_selectionModel) {
            if (contactDelegateItem.selectionModelIndex >= 0) {
                // If a contact is already selected, deselect it and do not emit contactClicked.
                _selectionModel.removeContactAt(contactDelegateItem.selectionModelIndex)
                return
            } else if (requiredContactProperty === PeopleModel.NoPropertyRequired) {
                // If the contact is not selected, it can be auto-selected if no property
                // selection is required; otherwise, the API user must call
                // selectContactProperty() before the contact can be selected.
                _selectionModel.addContact(contact.id, null, "")
            }
        }

        _activeDelegate = contactDelegateItem
        contactClicked(ContactsUtil.ensureContactComplete(contact, allContactsModel))
    }

    function _contactPressAndHold(contactDelegateItem, contact) {
        if (!contactDelegateItem) {
            console.log("Contact press+hold but no delegate specified!")
            return
        }
        _activeDelegate = contactDelegateItem
        contactPressAndHold(ContactsUtil.ensureContactComplete(contact, allContactsModel))
    }

    function _verifyActiveDelegateContact(contactId) {
        if (!contactId) {
            console.warn("Invalid contact ID")
            return false
        }
        if (!_activeDelegate) {
            console.warn("Cannot find an active contact delegate")
            return false
        }
        if (_activeDelegate.contactId !== contactId) {
            console.warn("Requested contactId", contactId,
                         "does not match id of last activated contact:", _activeDelegate.contactId)
            return false
        }
        return true
    }

    //---

    width: parent ? parent.width : Screen.width
    height: parent ? parent.height + pageStack.panelSize : Screen.height

    opacity: placeholder.enabled || _showInitialContent ? 1 : 0
    Behavior on opacity { FadeAnimator {} }

    SilicaListView {
        id: mainContactsList

        anchors.fill: parent
        quickScroll: false

        onMovementStarted: {
            // Delegates will be destroyed, so reset the active delegate.
            if (_activeDelegate) {
                _activeDelegate = null
            }
            trackContactsScrollPos.restart()
            _closeVirtualKeyboard()
        }

        onMovementEnded: {
            trackContactsScrollPos.stop()
        }

        header: Column {
            readonly property alias favoriteContactsSection: favoritesBar
            readonly property alias recentContactsSection: recentContactsList
            readonly property alias recentContactsCount: recentContactsList.count
            readonly property alias pageHeaderLoader: headerLoader
            readonly property alias searchFieldHeight: contactSearchField.height

            readonly property bool _embedSearchFieldInHeader: root._isLandscape && root.pageHeader != null
            property real _prevHeight: height

            function forceSearchFocus() {
                root.searchActive = true
                contactSearchField.forceActiveFocus()
            }

            width: parent.width
            visible: !placeholder.enabled

            onHeightChanged: {
                var delta = (height - _prevHeight)
                _prevHeight = height
                if (delta > 0) {
                    mainContactsList.contentY -= delta
                }
            }

            Item {
                id: headerContainer
                width: parent.width
                height: {
                    // Size this to contain the topMargin, the PageHeader and the search field.
                    // DialogHeader height can be ignored as that is already included as the
                    // topMargin.
                    var pageHeaderHeight = root._isDialog ? 0 : headerLoader.height
                    return root.topMargin
                            + (_embedSearchFieldInHeader
                               ? pageHeaderHeight
                               : (pageHeaderHeight + contactSearchField.height))
                }

                Loader {
                    id: headerLoader
                    width: parent.width
                    sourceComponent: root.pageHeader
                }

                // Search field is placed below the header in portrait orientation,
                // but in landscape orientation it is placed below the header only
                // if no pageHeader component is supplied.
                ContactSearchField {
                    id: contactSearchField

                    parent: _embedSearchFieldInHeader && !!headerLoader.item.extraContent
                            ? headerLoader.item.extraContent
                            : headerContainer
                    // When the search field is inside the header, center it within the parent.
                    // Otherwise, show it below the topMargin (or in a Page, below the PageHeader).
                    y: _embedSearchFieldInHeader
                       ? parent.height/2 - height/2
                       : root.topMargin + (root._isDialog ? 0 : headerLoader.height)
                    width: parent.width - symbolScrollBar.width/2

                    canHide: root.canHideSearchField
                             && text.length === 0
                             && !symbolScrollBar.pressed  // ensure 'x' doesn't overlap with scrollbar magnifier
                    active: root.searchActive

                    onTextChanged: {
                        root._searchPattern = text
                        if (text.length === 0) {
                            focus = true    // keep focus even when textfield is cleared
                        }
                    }

                    onHideClicked: {
                        root.searchActive = false
                    }

                    onActiveChanged: {
                        if (active) {
                            root._dynamicContactsModel.prepareSearchFilters()
                            forceSearchFocus()
                        }
                    }
                }
            }


            FavoritesBar {
                id: favoritesBar

                width: parent.width - symbolScrollBar.width
                visible: !root._searchFiltered

                favoritesModel: root.favoriteContactsModel
                selectionModel: root._selectionModel
                symbolScrollBarWidth: root._searchFiltered ? 0 : symbolScrollBar.width

                onContactPressed: _closeVirtualKeyboard()
                onContactClicked: root._contactClicked(delegateItem, contact)
                onContactPressAndHold: root._contactPressAndHold(delegateItem, contact)
                onMenuOpenChanged: root._setMenuOpen(menuOpen, menuItem)
            }

            SectionHeader {
                id: recentContactsHeader

                //% "Recent"
                text: qsTrId("components_contacts-he-recent")
                visible: !root._searchFiltered && recentContactsList.count > 0
                horizontalAlignment: Text.AlignLeft
            }

            RecentContactsList {
                id: recentContactsList

                visible: !root._searchFiltered
                recentContactsModel: _recentContactsModel
                contactsModel: allContactsModel
                selectionModel: root._selectionModel

                onContactPressed: _closeVirtualKeyboard()
                onContactClicked: root._contactClicked(delegateItem, contact)
                onContactPressAndHold: root._contactPressAndHold(delegateItem, contact)
                onMenuOpenChanged: root._setMenuOpen(menuOpen, menuItem)
            }
        }

        model: root._searchFiltered ? _dynamicContactsModel : allContactsModel

        section.property: root._searchFiltered ? "" : "sectionBucket"
        section.delegate: Label {
            x: Theme.horizontalPageMargin
            height: root._sectionHeaderHeight

            text: section
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
            verticalAlignment: Text.AlignVCenter
        }

        delegate: ContactBrowserItem {
            id: contactListDelegate

            width: root.width

            leftMarginOffset: root._searchFiltered && root._isLandscape && pageStack._pageStackIndicator && pageStack._pageStackIndicator.leftWidth
                              ? (pageStack._pageStackIndicator.leftWidth + Theme.paddingMedium)
                              : 0
            symbolScrollBarWidth: root._searchFiltered ? 0 : symbolScrollBar.width

            contactId: model.contactId
            selectionModel: root._selectionModel

            searchString: root._searchFiltered ? root._searchPattern : ""

            firstText: model.primaryName
            secondText: model.secondaryName
            matchText: typeof model.filterMatchData === "string" ? model.filterMatchData : model.filterMatchData.join(", ")
            unnamed: model.primaryName == allContactsModel.placeholderDisplayLabel
            presenceState: model.globalPresenceState

            onPressed: if (root._searchFiltered) _closeVirtualKeyboard()
            onMenuOpenChanged: symbolScrollBar.enabled = !menuOpen
            onContactClicked: root._contactClicked(contactListDelegate, contact)
            onContactPressAndHold: root._contactPressAndHold(contactListDelegate, contact)

            function getPerson() { return model.person } // access via on-demand call to prevent unnecessary initialization

            // Use custom gradient for background to avoid overlapping with symbol scrollbar.
            _backgroundColor: "transparent"
            ContactItemGradient {
                listItem: contactListDelegate
            }
        }

        Loader {
            id: placeholder
            width: parent.width
            enabled: allContactsModel.populated && allContactsModel.count == 0
            opacity: enabled ? 1.0 : 0.0
            Behavior on opacity { FadeAnimator {}}
            active: enabled
            onActiveChanged: if (active) active = true // remove binding
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: ViewPlaceholder {
                text: root.placeholderText
                enabled: placeholder.enabled // keep enabled even if parent changes to flickable
            }
        }
    }

    PeopleDisplayLabelGroupModel {
        id: displayLabelGroupModel

        requiredProperty: root._filterProperty
        maximumCount: symbolScrollBar.displayableSymbolCount

        onCountChanged: {
            // Update the highlighted symbol in case the current symbol no longer exists in the model.
            root._resetHighlightedSymbol()
        }
    }

    CommRecentContactsModel {
        id: _recentContactsModel

        limit: 5
        requiredProperty: root._filterProperty
        eventCategoryMask: CommHistory.AnyCategory
    }

    SailfishContacts.ContactSelectionModel {
        id: contactSelectionModel

        onSelectionAdded: {
            if (count == 1 && propertyType != undefined) {
                if (propertyType == 'accountUri' && root._isDialog) {
                    // No further selections are currently allowed - accept the dialog
                    root._page.accept()
                } else if (uniformSelectionTypes) {
                    // Further selections must be of the same type
                    if (propertyType == 'phoneNumber') {
                        root._filterProperty = PeopleModel.PhoneNumberRequired
                    } else if (propertyType == 'emailAddress') {
                        root._filterProperty = PeopleModel.EmailAddressRequired
                    } else if (propertyType == 'accountUri') {
                        root._filterProperty = PeopleModel.AccountUriRequired
                    }
                }
            }
        }

        onSelectionRemoved: {
            if (count == 0 && uniformSelectionTypes) {
                root._filterProperty = root.requiredContactProperty
            }
        }
    }

    Connections {
        target: allContactsModel
        onRowsAboutToBeRemoved: {
            var selectedRow = -1
            for (var i = first; i <= last; ++i) {
                selectedRow = contactSelectionModel.findContactId(allContactsModel.get(i, PeopleModel.ContactIdRole))
                if (selectedRow >= 0) {
                    contactSelectionModel.removeContactAt(selectedRow)
                }
            }
        }
    }

    SymbolScrollBar {
        id: symbolScrollBar

        x: root.width - width

        property int yOffset: {
            var pulley = mainContactsList.pullDownMenu
            if (pulley && pulley.active) {
                return -Math.min(0, mainContactsList.contentY - mainContactsList.originY)
            } else {
                return 0
            }
        }

        y: yOffset + root.topMargin + root.symbolScroller.topMargin
        width: visible ? implicitWidth : 0
        height: root.height - root.topMargin - root.symbolScroller.topMargin - root.symbolScroller.bottomMargin
        visible: hasSymbols && !root._searchFiltered && !placeholder.enabled
                 && mainContactsList.contentHeight - _scrollIgnoredContentHeight > mainContactsList.height
        opacity: root._showInitialContent && enabled ? 1 : 0

        favoriteIconEnabled: favoriteContactsModel.populated
                             && favoriteContactsModel.count > 0
        recentIconEnabled: _recentContactsModel.ready
                           && mainContactsList.headerItem
                           && mainContactsList.headerItem.recentContactsCount > 0
        model: displayLabelGroupModel

        onFavoriteIconClicked: {
            delayedScroll.scrollTo(mainContactsList.headerItem.favoriteContactsSection)
        }

        onRecentIconClicked: {
            delayedScroll.scrollTo(mainContactsList.headerItem.recentContactsSection)
        }

        onSymbolClicked: {
            if (symbolIndex === 0 && !favoriteIconEnabled && !recentIconEnabled) {
                delayedScroll.scrollTo(mainContactsList.headerItem.favoriteContactsSection)
            } else {
                delayedScroll.scrollTo(symbol)
            }
        }

        onFavoriteIconEnabledChanged: root._resetHighlightedSymbol()
        onRecentIconEnabledChanged: root._resetHighlightedSymbol()
    }

    Timer {
        id: delayedScroll

        function scrollTo(target) {
            mainContactsList.cancelFlick()
            trackContactsScrollPos.stop()

            _closeVirtualKeyboard()
            _scrollTarget = target
            restart()
        }

        property var _scrollTarget

        interval: 16

        onTriggered: {
            if (typeof _scrollTarget === "string") {
                root._scrollContactsTo(allContactsModel.firstIndexInGroup(_scrollTarget))
            } else {
                root._scrollContactsTo(_scrollTarget)
            }
        }
    }

    Timer {
        id: trackContactsScrollPos
        interval: 16

        onTriggered: {
            // The main contact list has been scrolled. Update the symbol scrollbar accordingly.
            root._resetHighlightedSymbol()

            // Pause before the next check for the first visible section. Use an interval
            // that scales to a higher value as the velocity gets slower, i.e. fire the timer
            // more frequently as the flicking speed increases.
            var velocityRatio = Math.abs(mainContactsList.verticalVelocity) / mainContactsList.maximumFlickVelocity
            interval = Math.max(1, 30 * (1 - velocityRatio))
            restart()
        }
    }
}
