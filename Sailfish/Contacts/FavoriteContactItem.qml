import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0 as Contacts
import org.nemomobile.contacts 1.0

GridItem {
    id: favoriteItem

    readonly property int contactId: model.contactId
    property bool canDeleteContact: true
    property var selectionModel
    readonly property int selectionModelIndex: selectionModel !== null ? (selectionModel.count > 0, selectionModel.findContactId(model.contactId)) : -1 // count to retrigger on change.
    property var propertyPicker

    property bool _hasAvatar: model.avatarUrl != ''

    property bool _pendingDeletion: Contacts.ContactModelCache._deletingContactId === contactId

    property int symbolScrollBarWidth

    Binding {
        target: favoriteItem
        when: !_showPress || menuOpen
        property: "_backgroundColor"
        value: _hasAvatar ? Theme.highlightDimmerColor : Theme.rgba(Theme.highlightBackgroundColor, 0.1)
    }

    function personObject() {
        return model.person
    }

    function deleteContact() {
        var item = remorseDelete(function () {
            favoritesModel.removePerson(model.person)
        })
        if (openRemorseBelow) {
            item.rightMargin = Theme.paddingMedium + symbolScrollBarWidth
        }
    }

    opacity: _pendingDeletion ? 0.0 : 1.0
    width: _pendingDeletion ? 0 : Theme.itemSizeExtraLarge
    contentHeight: width
    highlighted: down || menuOpen || selectionModelIndex >= 0
    contentItem.clip: !_hasAvatar

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
            visible: highlighted && !menuOpen
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
            width: parent.width
            font.pixelSize: Theme.fontSizeTiny
            truncationMode: TruncationMode.Fade
        }
        Label {
            text: model.title || model.role
            width: parent.width
            height: text.length > 0 ? implicitHeight : 0
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
}
