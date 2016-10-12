/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Ambience 1.0

ValueButton {
    id: toneItem

    property string defaultText
    property string currentText
    property string enabledProperty
    property string fileProperty
    property string title
    property bool toneEnabled

    label: defaultText
    title: info.displayName != "" ? info.displayName : metadataReader.getTitle(toneSettings[fileProperty])

    toneEnabled: toneSettings[enabledProperty]
    value: (title != "" && toneEnabled)
           ? title
             //% "No sound"
           : qsTrId("settings_sound-la-no_alarm_sound")

    onClicked: {
        var dialog = pageStack.push(dialogComponent, {
                        activeFilename: toneSettings[fileProperty],
                        activeSoundTitle: title,
                        activeSoundSubtitle: currentText,
                        noSound: !toneSettings[enabledProperty]
                        })

        dialog.accepted.connect(
            function() {
                if (dialog.selectedFilename != "") {
                    toneSettings[fileProperty] = dialog.selectedFilename
                }
                toneSettings[enabledProperty] = !dialog.noSound
            })
     }
    ContentInfo {
        id: info

        property string displayName
        url: "file://" + toneSettings[fileProperty]
    }
}
