/****************************************************************************
**
** Copyright (c) 2018 - 2019 Jolla Ltd.
** Copyright (c) 2020 Open Mobile Platform LLC.
** License: Proprietary
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Ambience 1.0

Dialog {
    id: dialog

    property alias contentId: view.contentId
    property alias ambience: view.ambience

    palette {
        primaryColor: ambience.primaryColor
        secondaryColor: ambience.secondaryColor
        highlightColor: ambience.highlightColor
        secondaryHighlightColor: ambience.secondaryHighlightColor
        colorScheme: ambience.colorScheme
    }

    onAccepted: {
        ambience.save()
        Ambience.source = ambience.url
    }

    // JB#41666: Don't create ambience before user has accepted the dialog
    onRejected: ambience.remove()
    Component.onDestruction: if (result !== DialogResult.Accepted) ambience.remove()

    allowedOrientations: Orientation.All

    background: Wallpaper {
        palette {
            primaryColor: ambience.primaryColor
            secondaryColor: ambience.secondaryColor
            highlightColor: ambience.highlightColor
            secondaryHighlightColor: ambience.secondaryHighlightColor
            colorScheme: ambience.colorScheme
        }

        sourceItem: view.applicationWallpaper
    }

    DialogHeader {
        id: dialogHeader

        spacing: 0
    }

    AmbienceSettingsView {
        id: view

        y: dialogHeader.height

        width: dialog.width
        height: dialog.height - y

        showWallpaper: false
        fadeAmbiencePicture: true
        enableColorSchemeSelection: true

        clip: true

        Label {
            //% "Create ambience"
            text: qsTrId("jolla-gallery-ambience-la-create-ambience")

            color: ambience.highlightColor
            x: Theme.horizontalPageMargin
            y: Theme.paddingMedium
            width: parent.width - 2*x
            font.pixelSize: Theme.fontSizeExtraLarge
            wrapMode: Text.Wrap
        }
    }
}
