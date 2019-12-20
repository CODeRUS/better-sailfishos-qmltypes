import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Ambience 1.0
import Sailfish.Gallery 1.0
import org.nemomobile.thumbnailer 1.0

SilicaListView {
    id: ambienceList

    property bool initialized
    onCountChanged: if (count > 0) initialized = true

    property real itemHeight: Screen.sizeCategory >= Screen.Large
        ? Theme.itemSizeExtraLarge + (2 * Theme.paddingLarge)
        : Screen.height / 5

    property real exposure: height
    property real _effectiveExposure: currentItem
            ? exposure + currentItem.height - itemHeight
            : exposure

    readonly property bool largeScreen: Screen.sizeCategory >= Screen.Large

    signal ambienceSelected(var ambience)

    delegate: ListItem {
        id: listItem

        property Item _remorse
        function remorse() {
            if (!_remorse) {
                _remorse = remorseComponent.createObject(listItem)
            }
            return _remorse
        }

        property bool active: Ambience.source == url
        onActiveChanged: {
            if (active) {
                selectionHighlight.parent = listItem
            } else if (selectionHighlight.parent == listItem) {
                selectionHighlight.parent = null
            }
        }

        x: Screen.sizeCategory >= Screen.Large ? Theme.horizontalPageMargin : 0
        width: ambienceList.width - (2 * x)
        contentHeight: ambienceList.itemHeight

        baselineOffset: displayNameLabel.y + (displayNameLabel.height / 2)

        highlighted: false

        onPressed: ambienceList.currentIndex = index
        onClicked: ambienceList.ambienceSelected(model)

        menu: Component {
            ContextMenu {
                id: contextMenu

                MenuItem {
                    enabled: !listItem.active
                    // Defined in AmbienceSettingsPage.qml
                    text: qsTrId("jolla-gallery-ambience-me-set_ambience")
                    onClicked: ambienceList.model.makeCurrent(model.index)
                }
                MenuItem {
                    text: favorite
                            //% "Remove from favorites"
                            ? qsTrId("jolla-gallery-ambience-me-remove_from_favorites")
                            //% "Add to favorites"
                            : qsTrId("jolla-gallery-ambience-me-add_to_favorites")
                    onClicked: ambienceList.model.setProperty(model.index, "favorite", !favorite)
                }
                MenuItem {
                    // Defined in AmbienceSettingsPage.qml
                    text: qsTrId("jolla-gallery-ambience-me-remove_ambience")
                    enabled: !listItem.active
                    onClicked: {
                        listItem.remorse().execute(
                                    listItem,
                                    qsTrId("jolla-gallery-ambience-delete-ambience"))
                    }
                }
            }
        }

        ListView.delayRemove: removeAnimation.running
        ListView.onRemove: SequentialAnimation {
            id: removeAnimation
            running: false
            FadeAnimation { target: listItem; to: 0; duration: 200 }
            NumberAnimation { target: listItem; properties: "height"; to: 0; duration: 200; easing.type: Easing.InOutQuad }
        }

        ListView.onAdd: SequentialAnimation {
            running: false
            PropertyAction { target: listItem; properties: "opacity"; value: 0 }
            NumberAnimation {
                target: listItem
                properties: "height"
                from: 0
                to: listItem.contentHeight
                duration: initialized ? 200 : 0
                easing.type: Easing.InOutQuad
            }
            FadeAnimation { target: listItem; to: 1; duration: initialized ? 200 : 0 }

            onStopped: listItem.height = undefined
        }

        Thumbnail {
            id: thumbnail

            anchors.fill: parent
            sourceSize { width: width; height: height }

            source: wallpaperUrl != undefined ? wallpaperUrl : ""

            onStatusChanged: {
                if (status == Thumbnail.Error) {
                    errorLabelComponent.createObject(thumbnail)
                }
            }
        }

        Rectangle {
            anchors.fill: parent

            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0.0 ,0.0, 0.0, Theme.opacityHigh) }
            }
        }

        Label {
            id: displayNameLabel
            anchors {
                left: parent.left
                leftMargin: Theme.paddingLarge
                right: favoriteIcon.left
                rightMargin: Theme.paddingLarge
                bottom: parent.bottom
                bottomMargin: Theme.paddingMedium
            }
            font.pixelSize: Theme.fontSizeLarge
            truncationMode: TruncationMode.Fade
            text: displayName
            color: model.highlightColor ? Theme.highlightFromColor(model.highlightColor, Theme.LightOnDark)
                                        : Theme.highlightColor
        }

        MouseArea {
            id: favoriteButton
            anchors {
                fill: favoriteIcon
                margins: -Theme.paddingLarge
            }
            onClicked: ambienceList.model.setProperty(model.index, "favorite", !favorite)
        }

        Icon {
            id: favoriteIcon

            palette.colorScheme: Theme.LightOnDark
            source: favorite ? "image://theme/icon-m-favorite-selected"
                             : "image://theme/icon-m-favorite"
            anchors {
                right: parent.right
                rightMargin: Theme.paddingLarge
                verticalCenter: displayNameLabel.verticalCenter
            }
            highlighted: favoriteButton.containsPress
        }

        Component {
            id: remorseComponent
            RemorseItem {
                onTriggered: ambienceList.model.remove(index)
            }
        }
    }

    Rectangle {
        readonly property bool highlighting: ambienceList.currentItem && ambienceList.currentItem.down
                                             && !ambienceList.currentItem.menuOpen

        parent: ambienceList.contentItem
        anchors.fill: ambienceList.currentItem

        visible: highlighting || highlightAnimation.running
        opacity: highlighting ? Theme.opacityHigh : 0.0
        Behavior on opacity { FadeAnimation { id: highlightAnimation; duration: 100 } }

        color: Theme.highlightBackgroundColor
        z: 2
    }

    VerticalScrollDecorator {}

    Item {
        id: selectionHighlight

        parent: null
        width: selectionGraphic.width / 2
        height: selectionGraphic.height
        anchors {
            verticalCenter: parent ? parent.baseline : undefined
            left: parent ? parent.left : undefined
        }

        GlassItem {
            id: selectionGraphic

            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.left
            }

            color: Theme.lightPrimaryColor
            backgroundColor: palette.backgroundGlowColor
            radius: 0.22
            falloffRadius: 0.18
            clip: true
        }
    }

    Component {
        id: errorLabelComponent
        Label {
            //: Thumbnail Image loading failed
            //% "Oops, can't display the thumbnail!"
            text: qsTrId("jolla-gallery-ambience-la-image-thumbnail-loading-failed")
            anchors.centerIn: parent
            width: parent.width - 2 * Theme.paddingMedium
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
