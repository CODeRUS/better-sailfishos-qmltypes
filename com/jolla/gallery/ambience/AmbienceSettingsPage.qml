import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as SilicaPrivate
import Sailfish.Ambience 1.0

Page {
    id: root

    property alias contentId: view.contentId
    property alias ambience: view.ambience
    readonly property bool wasRemoved: _removed || removeRemorse.visible
    property bool _removed

    // Save only when user leaves the app or goes back to the previous page
    onStatusChanged: {
        if (status === PageStatus.Deactivating && !view.wasRemoved) {
            view.ambience.commitChanges()
        } else if (status === PageStatus.Inactive) {
            view.contentY = 0
        }
    }
    allowedOrientations: Orientation.All

    SilicaPrivate.Wallpaper {
        id: wallpaper
        width: parent.width
        height: Math.max(0, -view.contentY +  view.backgroundHeight)
        windowRotation: -root.rotation
        source: ambience.applicationWallpaperUrl
        colorScheme: ambience.colorScheme
    }

    AmbienceSettingsView {
        id: view

        PullDownMenu {
            visible: Ambience.source != ambience.url
            highlightColor: ambience.highlightColor
            backgroundColor: Theme.highlightBackgroundFromColor(ambience.highlightColor, ambience.colorScheme)

            MenuItem {
                //: Remove ambience from the ambience list
                //% "Remove ambience"
                text: qsTrId("jolla-gallery-ambience-me-remove_ambience")
                color: down || highlighted ? ambience.primaryColor : ambience.highlightColor
                onClicked: {
                    //: Remorse popup text for ambience deletion
                    //% "Deleting Ambience"
                    removeRemorse.execute(qsTrId("jolla-gallery-ambience-delete-ambience"),
                                          function() {
                                              root._removed = true
                                              ambience.remove()
                                              pageStack.pop()
                                          })
                }
            }
            MenuItem {
                //: Active the ambience
                //% "Set Ambience"
                text: qsTrId("jolla-gallery-ambience-me-set_ambience")
                color: down || highlighted ? ambience.primaryColor : ambience.highlightColor
                onClicked: {
                    ambience.save()
                    Ambience.source = ambience.url
                }
            }
        }
    }

    RemorsePopup { id: removeRemorse }
}
