import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import org.nemomobile.contacts 1.0

Item {
    id: favoriteBar

    property var favoritesModel
    property ContactSelectionModel selectionModel

    property int columns: width / avatarSize
    property bool menuOpen
    property Item menuItem

    readonly property int avatarSize: {
        // use the maximum size available depending on the minimum number of columns
        var minColumnCount = Math.floor(width / _minAvatarSize)
        return width / minColumnCount
    }

    // Avatar area fits minimum of 2 name lines + 2 company info lines + padding.
    readonly property int _minAvatarSize: Theme.paddingMedium + (nameFont.height * 2)
                                          + Theme.paddingSmall + (companyInfoFont.height * 2)
                                          + Theme.paddingMedium
    property bool _transitionsEnabled: allowAnimations.running && !pageStack.currentPage.orientationTransitionRunning

    signal contactClicked(var delegateItem, var contact)
    signal contactPressed()
    signal contactPressAndHold(var delegateItem, var contact)

    width: parent.width
    height: grid.height

    FontMetrics {
        id: nameFont
        font.pixelSize: Theme.fontSizeMedium
    }

    FontMetrics {
        id: companyInfoFont
        font.pixelSize: Theme.fontSizeTiny
    }

    Timer {
        id: allowAnimations
        interval: 400   // roughly after animations complete
    }

    // Only run the add/move animations when the model changes. Otherwise they are triggered
    // when populating the model, or when the grid's overall dimensions change, or a context menu
    // opens within the grid, etc. Using a timer for this is hacky but it's hard to calculate
    // precisely when all add/move transitions have ended e.g. if a transition gets canceled.
    Connections {
        target: favoritesModel
        onCountChanged: {
            if (favoritesModel.populated) {
                allowAnimations.restart()
            }
        }
    }

    Grid {
        id: grid
        columns: favoriteBar.columns
        width: columns * favoriteBar.avatarSize

        add: Transition {
            id: add
            enabled: favoriteBar._transitionsEnabled

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
            enabled: favoriteBar._transitionsEnabled

            SequentialAnimation {
                id: favoriteItemAnimation

                readonly property bool changingY: {
                    if (!move.ViewTransition.item) {
                        return false
                    }
                    // Animate if the item is moving to first/last column. targetIndexes is only
                    // set when triggered by insertions but not removals, so for insertions check
                    // for a move to the first column, and for removals check for a move to the last.
                    var col = Math.floor(move.ViewTransition.index % grid.columns)
                    return move.ViewTransition.targetIndexes.length > 0 ? col === 0 : col === grid.columns-1
                }

                NumberAnimation {
                    properties: "opacity"
                    duration: 75
                    from: 1
                    to: favoriteItemAnimation.changingY ? 0 : 1
                }
                PauseAnimation {
                    duration: favoriteItemAnimation.changingY ? 150 : 0
                }
                NumberAnimation {
                    properties: "x,y"
                    easing.type: Easing.InOutQuad
                    duration: favoriteItemAnimation.changingY ? 0 : 150
                }
                NumberAnimation {
                    properties: "opacity"
                    duration: 75
                    from: favoriteItemAnimation.changingY ? 0 : 1
                    to: 1
                }
            }
        }

        Repeater {
            id: repeater
            model: favoritesModel

            FavoriteContactItem {
                id: contactItem

                width: favoriteBar.avatarSize
                selectionModel: favoriteBar.selectionModel

                onPressed: contactPressed()
                onPressAndHold: contactPressAndHold(contactItem, model.person)
                onClicked: contactClicked(contactItem, model.person)

                onMenuOpenChanged: {
                    if (menuOpen) {
                        favoriteBar.menuItem = _contextMenu
                    } else if (favoriteBar.menuItem === _contextMenu) {
                        favoriteBar.menuItem = null
                    }
                    favoriteBar.menuOpen = menuOpen
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

                x: -x - parent.x
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
                    rightMargin: Theme.paddingMedium
                }

                Component.onDestruction: destroyAnim.start()
            }
        }
    }
}
