import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0 as Contacts
import org.nemomobile.contacts 1.0

Item {
    id: favoriteItem

    readonly property int contactId: model.contactId
    property bool canDeleteContact: true
    property var selectionModel
    readonly property int selectionModelIndex: selectionModel !== null ? (selectionModel.count > 0, selectionModel.findContactId(model.contactId)) : -1 // count to retrigger on change.
    property var propertyPicker

    property var menu
    readonly property bool menuOpen: _contextMenuHeight
    property alias highlighted: backgroundItem.highlighted

    signal clicked()
    signal pressed()
    signal pressAndHold()

    property bool _hasAvatar: model.avatarUrl != ''
    property Item _contextMenu
    property Item _remorseItem

    property real _contextMenuHeight: _contextMenu !== null ? _contextMenu.height : 0
    property real _remorseItemHeight: _remorseItem !== null ? _remorseItem.height : 0
    property bool _menuOrRemorseOpen: menuOpen || _remorseItemHeight
    property bool _pendingDeletion: Contacts.ContactModelCache._deletingContactId === contactId

    function openMenu(properties) {
        if (_contextMenu) {
            _contextMenu.destroy()
        }
        _contextMenu = menu.createObject(favoriteItem, properties)
        _contextMenu.open(favoriteItem)
    }

    function personObject() {
        return model.person
    }

    function deleteContact() {
        if (menuOpen) {
            // Delay deletion to avoid showing both menu and remorse item at the same time.
            delayedContactDeletion.target = _contextMenu
            return
        }

        if (!removalComponent) {
            return
        }

        _remorseItem = removalComponent.createObject(favoriteItem)
        _remorseItem.remorse.execute(_remorseItem, _remorseItem.text,
                                         function() { favoritesModel.removePerson(model.person) })
    }

    function _confirmOrCancelRemorse() {
        if (_remorseItemHeight) {
            _remorseItem.remorse.cancel()
        } else if (_remorseItem !== null) {
            if (_contextMenu) {
                _contextMenu.destroy()
                _contextMenu = null
            }
            _remorseItem.remorse._timeout=0
        }
    }

    opacity: _pendingDeletion ? 0.0 : 1.0
    width: _pendingDeletion ? 0 : Theme.itemSizeExtraLarge
    height: _pendingDeletion ? 0 : width + _contextMenuHeight + _remorseItemHeight

    BackgroundItem {
        id: backgroundItem

        // user chose to delete the item. hide the item during undo period
        opacity: _remorseItem && _remorseItem.remorse.pending ? 0.0 : 1.0
        highlighted: down || _menuOrRemorseOpen || favoriteItem.selectionModelIndex >= 0

        // copied from Sailfish.Silica ListItem
        _backgroundColor: _showPress && !_menuOrRemorseOpen ? Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                                                  : (_hasAvatar ? Theme.highlightDimmerColor : Theme.rgba(Theme.highlightBackgroundColor, 0.1))

        width: parent.width
        height: width
        clip: !_hasAvatar

        onClicked: {
            _confirmOrCancelRemorse()
            favoriteItem.clicked()
        }

        Image {
            id: favoriteImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: _hasAvatar ? model.avatarUrl : "image://theme/graphic-avatar-text-back"
            clip: _hasAvatar

            Rectangle {
                anchors.fill: parent
                color: Theme.highlightColor
                opacity: Theme.highlightBackgroundOpacity
                visible: backgroundItem.highlighted
            }
        }

        OpacityRampEffect {
            enabled: _hasAvatar && presence.visible
            sourceItem: favoriteImage
            direction: OpacityRamp.TopToBottom
            offset: 0.7
            slope: 3.0
        }

        Column {
            visible: !_hasAvatar
            anchors {
                margins: Theme.paddingMedium
                top: parent.top
                left: parent.left
                right: parent.right
            }

            Label {
                text: model.primaryName
                color: backgroundItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                width: parent.width
                height: text.length > 0 ? implicitHeight : 0
                font {
                    family: Theme.fontFamilyHeading
                    pixelSize: Theme.fontSizeMedium
                }
                truncationMode: TruncationMode.Fade
            }
            Label {
                text: model.secondaryName
                width: parent.width
                color: backgroundItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                font {
                    family: Theme.fontFamilyHeading
                    pixelSize: Theme.fontSizeMedium
                }
                truncationMode: TruncationMode.Fade
            }
        }

        Column {
            visible: !_hasAvatar
            anchors {
                margins: Theme.paddingMedium
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            Label {
                text: model.companyName
                color: backgroundItem.highlighted ? Theme.secondaryHighlightColor : Theme.highlightColor
                width: parent.width
                font.pixelSize: Theme.fontSizeTiny
                truncationMode: TruncationMode.Fade
            }
            Label {
                text: model.title || model.role
                width: parent.width
                height: text.length > 0 ? implicitHeight : 0
                color: backgroundItem.highlighted ? Theme.secondaryHighlightColor : Theme.highlightColor
                font.pixelSize: Theme.fontSizeTiny
                truncationMode: TruncationMode.Fade
            }
        }

        ContactPresenceIndicator {
            id: presence
            visible: !offline
            anchors {
                left: parent.left
                leftMargin: Theme.paddingMedium
                bottom: parent.bottom
                bottomMargin: Theme.paddingSmall
            }
            presenceState: model.globalPresenceState
        }

        onPressed: favoriteItem.pressed()

        onPressAndHold: {
            _confirmOrCancelRemorse()
            favoriteItem.pressAndHold()
        }
    }

    Connections {
        id: delayedContactDeletion
        target: null
        onClosed: {
            deleteContact()
            target = null
        }
    }

}
