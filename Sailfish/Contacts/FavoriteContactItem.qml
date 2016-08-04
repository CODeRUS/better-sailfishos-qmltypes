import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Telephony 1.0
import org.nemomobile.contacts 1.0
import "common/common.js" as ContactsUtils

Item {
    id: favoriteItem

    property bool menuOpen: _contextMenuHeight || _propertyMenuHeight || _remorseItemHeight
    property bool selected
    property int requiredProperty
    property alias highlighted: backgroundItem.highlighted

    signal clicked(variant property, string propertyType)
    signal pressed

    property bool _hasAvatar: model.avatarUrl != ''

    property Item _contextMenu
    property Item _remorseItem
    property Item _propertyMenu

    property real _contextMenuHeight: _contextMenu !== null ? _contextMenu.height : 0
    property real _remorseItemHeight: _remorseItem !== null ? _remorseItem.height : 0
    property real _propertyMenuHeight: _propertyMenu !== null ? _propertyMenu.height : 0

    function getSelectableProperties() {
        // Ensure the import is initialized
        ContactsUtils.init(Person)
        return ContactsUtils.selectableProperties(model, root.requiredProperty, Person)
    }

    function _openContextMenu(person) {
        if (!_contextMenu) {
            _contextMenu = contextMenuComponent.createObject(favoriteItem, {"person": person})
        }
        _contextMenu.x = -favoriteItem.x
        _contextMenu.show(favoriteItem)
    }

    function _openPropertyMenu(addresses) {
        if (!_propertyMenu) {
            _propertyMenu = propertyMenuComponent.createObject(favoriteItem)
        }
        _propertyMenu.addressesModel.setAddresses(addresses)
        _propertyMenu.x = -favoriteItem.x
        _propertyMenu.show(favoriteItem)
    }

    function remove(contactIdCheck) {
        if (!removalComponent ||
            (contactIdCheck != undefined && model.contactId != contactIdCheck)) {
            return
        }

        _remorseItem = removalComponent.createObject(favoriteItem)
        //: Deleting image in 5 seconds
        //% "Deleting"
        _remorseItem.remorse.execute(_remorseItem, qsTrId("components_contacts-me-deleting"),
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
    width: Theme.itemSizeExtraLarge
    height: width + _contextMenuHeight + _remorseItemHeight + _propertyMenuHeight

    BackgroundItem {
        id: backgroundItem

        highlighted: down || favoriteItem.menuOpen || favoriteItem.selected

        // copied from Sailfish.Silica ListItem
        _backgroundColor: _showPress && !menuOpen ? Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                                                  : (_hasAvatar ? Theme.highlightDimmerColor : Theme.rgba(Theme.highlightBackgroundColor, 0.1))

        width: parent.width
        height: width
        clip: !_hasAvatar

        onClicked: {
            _confirmOrCancelRemorse()

            var selectedProperty = { "property": undefined, "propertyType": "" }
            var properties = getSelectableProperties()

            if (!selected && properties) {
                if (properties.length > 1) {
                    _openPropertyMenu(properties)
                    return
                }

                selectedProperty = properties[0]
            }

            if (selectedProperty.propertyType == 'phoneNumber' && Telephony.voiceSimUsageMode == Telephony.AlwaysAskSim) {
                // Select a SIM via menu
                _openPropertyMenu(properties)
                _propertyMenu.property = selectedProperty.property
                _propertyMenu.type = selectedProperty.propertyType
                _propertyMenu.simPickerActive = true
                return
            }

            favoriteItem.clicked(selectedProperty.property, selectedProperty.propertyType)
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
                opacity: 0.3
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
                topMargin: Theme.paddingSmall
                leftMargin: Theme.paddingMedium
                rightMargin: Theme.paddingMedium
            }

            Label {
                id: firstName
                text: model.primaryName
                color: backgroundItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                width: parent.width
                font {
                    family: Theme.fontFamilyHeading
                    pixelSize: Theme.fontSizeMedium
                }
                truncationMode: TruncationMode.Fade
            }
            Label {
                id: lastName
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
        ContactPresenceIndicator {
            id: presence
            visible: !offline
            anchors {
                left: parent.left
                leftMargin: Theme.paddingMedium
                bottom: parent.bottom
                bottomMargin: Theme.paddingMedium
            }
            presenceState: model.globalPresenceState
        }


        onPressed: favoriteItem.pressed()

        onPressAndHold: {
            if (!contextMenuComponent)
                return

            _confirmOrCancelRemorse()

            _openContextMenu(model.person)
        }

        Component {
            id: propertyMenuComponent

            ContextMenu {
                id: contextMenu

                property ContactAddressesModel addressesModel: ContactAddressesModel {
                    requiredProperty: favoriteItem.requiredProperty
                }
                property var property
                property string type
                property alias simPickerActive: simPicker.active

                SimPickerMenuItem {
                    id: simPicker
                    menu: contextMenu
                    fadeAnimationEnabled: addressesModel.count > 1
                    onSimSelected: {
                        property['modemPath'] = modemPath
                        favoriteItem.clicked(property, type)
                    }
                }

                Repeater {
                    model: contextMenu.addressesModel
                    MenuItem {
                        text: displayLabel
                        onClicked: {
                            if (type == 'phoneNumber' && Telephony.voiceSimUsageMode == Telephony.AlwaysAskSim) {
                                contextMenu.property = property
                                contextMenu.type = type
                                simPicker.active = true
                            } else {
                                favoriteItem.clicked(property, type)
                            }
                        }
                    }
                }
            }
        }
    }
}
