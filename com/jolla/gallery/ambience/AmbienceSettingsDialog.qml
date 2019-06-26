import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as SilicaPrivate
import Sailfish.Ambience 1.0

Dialog {
    id: dialog

    property alias contentId: view.contentId
    property alias ambience: view.ambience

    onAccepted: {
        ambience.save()
        Ambience.source = ambience.url
    }

    // JB#41666: Don't create ambience before user has accepted the dialog
    onRejected: ambience.remove()
    Component.onDestruction: if (result !== DialogResult.Accepted) ambience.remove()

    allowedOrientations: Orientation.All

    SilicaPrivate.Wallpaper {
        anchors.fill: parent
        source: ambience.applicationWallpaperUrl
        windowRotation: -dialog.rotation
        colorScheme: ambience.colorScheme
    }

    AmbienceSettingsView {
        id: view

        showWallpaper: false
        fadeAmbiencePicture: true
        primaryColor: ambience.primaryColor
        secondaryColor: ambience.secondaryColor
        highlightColor: ambience.highlightColor
        secondaryHighlightColor: ambience.secondaryHighlightColor
        colorScheme: ambience.colorScheme
        enableColorSchemeSelection: true

        topHeader: DialogHeader {
            id: dialogHeader

            Label {
                //% "Create ambience"
                text: qsTrId("jolla-gallery-ambience-la-create-ambience")

                parent: dialogHeader
                color: ambience.highlightColor
                x: Theme.horizontalPageMargin
                y: parent.height + Theme.paddingMedium
                width: parent.width - 2*x
                font.pixelSize: Theme.fontSizeExtraLarge
                wrapMode: Text.Wrap
            }

            SilicaPrivate.Wallpaper {
                z: -1
                parent: dialogHeader
                anchors.fill: parent
                source: ambience.applicationWallpaperUrl
                windowRotation: -dialog.rotation
                colorScheme: ambience.colorScheme
            }
        }
    }
}
