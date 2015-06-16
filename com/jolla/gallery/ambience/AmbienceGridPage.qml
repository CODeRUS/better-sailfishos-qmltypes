import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Silica.theme 1.0
import Sailfish.Ambience 1.0
import com.jolla.gallery 1.0
import org.nemomobile.thumbnailer 1.0
import QtGraphicalEffects 1.0

MediaSourcePage {
    id: gridPage

    property string albumIdentifier
    property variant model // Not used by this page
    property string title
    allowedOrientations: window.allowedOrientations

    function showAmbienceSettings(properties)
    {
        pageStack.push(Qt.resolvedUrl("AmbienceSettingsPage.qml"), properties)
    }

    AmbienceModel {
        id: ambienceModelFaves
        filter: AmbienceModel.FavoritesOnly
    }

    AmbienceModel {
        id: ambienceModelNoFaves
        filter: AmbienceModel.NonFavoritesOnly
    }


    SilicaFlickable {
        id: grid
        anchors.fill: parent
        contentHeight: content.height
        contentWidth: content.width

        Column {
            id: content
            width: parent.width

            PageHeader { title: gridPage.title; width: grid.width }

            ImageGridView {
                id: favoriteGrid

                width: grid.width
                height: Math.ceil(ambienceModelFaves.count / columnCount) * cellSize
                columnCount: Math.floor(width / (2 * Theme.itemSizeExtraLarge))
                interactive: false
                model: ambienceModelFaves
                add: Transition { NumberAnimation { properties: "opacity"; from: 0; to: 1; easing.type: Easing.InOutQuad; duration: 400 } }
                remove: Transition { NumberAnimation { properties: "opacity"; from: 1; to: 0; easing.type: Easing.InOutQuad; duration: 400 } }

                delegate: ThumbnailImage {
                    id: faveDelegate
                    source: wallpaperUrl
                    size: favoriteGrid.cellSize

                    onClicked: showAmbienceSettings({ "ambienceModel": window.ambienceModel, "source": url })
                    LinearGradient {
                        anchors.fill: parent
                        start: Qt.point(0, 0)
                        end: Qt.point(0, parent.height)
                        gradient: Gradient {
                            GradientStop { position: 0.5; color: "transparent"}
                            GradientStop { position: 1.0; color: Theme.highlightDimmerColor }
                        }
                    }

                    Label {
                        id: displayNameLabel
                        anchors {
                            left: parent.left
                            bottom: parent.bottom
                            leftMargin: Theme.paddingLarge
                            bottomMargin: Theme.paddingLarge
                        }
                        color: down ? Theme.highlightColor : highlightColor
                        width: parent.width - 2 * Theme.paddingLarge
                        font.pixelSize: Theme.fontSizeMedium
                        horizontalAlignment: Text.AlignLeft
                        text: displayName
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        truncationMode: TruncationMode.Elide
                    }
                }
            }

            ImageGridView {
                id: nonFaveGrid
                width: grid.width
                height: Math.ceil(ambienceModelNoFaves.count / columnCount) * cellSize
                model: ambienceModelNoFaves
                interactive: false
                add: Transition { NumberAnimation { properties: "opacity"; from: 0; to: 1; easing.type: Easing.InOutQuad; duration: 400 } }
                remove: Transition { NumberAnimation { properties: "opacity"; from: 1; to: 0; easing.type: Easing.InOutQuad; duration: 400 } }

                delegate:  ThumbnailImage {
                    id: thumbnail
                    source: wallpaperUrl
                    size: nonFaveGrid.cellSize

                    onClicked: showAmbienceSettings({ "ambienceModel": window.ambienceModel, "source": url })
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
