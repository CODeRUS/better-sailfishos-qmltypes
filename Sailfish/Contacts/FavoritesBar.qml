import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0

Item {
    id: favoriteBar

    property PeopleModel favoritesModel
    property ListModel selectionModel
    property int requiredProperty
    property alias heightAnimationEnabled: heightAnimation.enabled

    property Component contextMenuComponent

    signal contactClicked(variant contactItem, variant contact, variant property, string propertyType)
    signal contactPressed()

    function _toggleSelection(contact, property, propertyType) {
        if (selectionModel) {
            var selectionIndex = selectionModel.findContact(contact)
            if (selectionIndex >= 0) {
                selectionModel.removeContactAt(selectionIndex)
            } else {
                var secondary = contact.secondaryName
                var formattedName = contact.primaryName + (secondary == '' ? '' : ' ' + secondary)
                selectionModel.addContact(contact, !contact.favorite, formattedName, property, propertyType)
            }
        }
    }

    width: parent.width
    height: grid.height
    Behavior on height {
        id: heightAnimation
        enabled: false

        NumberAnimation {
            duration: 150
            easing.type: Easing.InOutQuad
        }
    }
    Timer {
        running: heightAnimation.enabled
        interval: 1
        onTriggered: heightAnimation.enabled = false
    }

    Grid {
        id: grid
        columns: Math.floor(parent.width / Theme.itemSizeExtraLarge)

        width: columns * Theme.itemSizeExtraLarge
        anchors.horizontalCenter: parent.horizontalCenter

        property bool transitionsEnabled: _enableTransitions
        property bool _enableTransitions
        property bool _populated: favoritesModel.populated
        on_PopulatedChanged: {
            if (_populated && !_enableTransitions) {
                readyTimer.restart()
            }
        }
        Timer {
            id: readyTimer
            interval: 1
            onTriggered: grid._enableTransitions = true
        }

        add: Transition {
            id: add
            enabled: grid.transitionsEnabled

            SequentialAnimation {
                PropertyAction {
                    target: add.ViewTransition.item
                    property: "opacity"
                    value: 0
                }
                PauseAnimation {
                    duration: 225
                }
                NumberAnimation {
                    properties: "opacity"
                    duration: 75
                    from: 0
                    to: 1
                }
            }
        }
        move: Transition {
            id: move
            enabled: grid.transitionsEnabled

            SequentialAnimation {
                PropertyAction {
                    property: "dummy"
                    value: {
                        // Updating changingY as a side-effect works around an issue where the value is
                        // seemingly updated correctly in the PropertyAction, but this does not have the
                        // desired effect on the bound properties of the animations...
                        move.ViewTransition.item.changingY = Math.abs(move.ViewTransition.item.y - move.ViewTransition.destination.y) > 1
                        return true
                    }
                }
                NumberAnimation {
                    properties: "opacity"
                    duration: 75
                    from: 1
                    to: move.ViewTransition.item.changingY ? 0 : 1
                }
                PauseAnimation {
                    duration: move.ViewTransition.item.changingY ? 150 : 0
                }
                NumberAnimation {
                    properties: "x,y"
                    easing.type: Easing.InOutQuad
                    duration: move.ViewTransition.item.changingY ? 0 : 150
                }
                NumberAnimation {
                    properties: "opacity"
                    duration: 75
                    from: move.ViewTransition.item.changingY ? 0 : 1
                    to: 1
                }
            }
        }

        Repeater {
            id: repeater
            model: favoritesModel

            FavoriteContactItem {
                id: contactItem
                selected: selectionModel !== null && selectionModel.findContactId(contactId) >= 0
                requiredProperty: favoriteBar.requiredProperty

                onPressed: contactPressed()
                onClicked: {
                    _toggleSelection(model.person, property, propertyType)
                    contactClicked(contactItem, model.person, property, propertyType)
                }

                // Used to control move transition for this delegate
                property bool changingY
                // Dummy value to update, so that we can update 'changingY' as a side-effect
                property bool dummy

                Binding {
                    when: contactItem.highlighted
                    target: grid
                    property: 'transitionsEnabled'
                    value: false
                }
            }
        }

        Component {
            id: removalComponent
            Item {
                id: remorseContainer
                property alias remorse: remorseItem

                function clear() {
                    remorseContainer.destroy()
                }

                y: parent.height - height
                width: favoriteBar.width
                height: Theme.itemSizeSmall

                SequentialAnimation {
                    id: destroyAnim
                    NumberAnimation { target: remorseContainer; property: "height"; to: 0; duration: 200 }
                    ScriptAction { script: remorseContainer.clear() }
                }

                RemorseItem {
                    id: remorseItem
                    onTriggered: destroyAnim.start()
                    onCanceled: destroyAnim.start()
                }

                Component.onDestruction: destroyAnim.start()
            }
        }
    }
}
