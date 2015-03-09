import QtQuick 2.0
import Sailfish.Silica 1.0

ValueButton {
    id: toneItem

    property string defaultText
    property string currentText
    property string enabledProperty
    property string fileProperty
    property string displayNameProperty
    property string title
    property bool toneEnabled

    function getTitle()
    {
        var displayTitle
        if (displayNameProperty) {
            displayTitle = toneSettings[displayNameProperty]
        }

        if (displayTitle === "") {
            displayTitle = metadataReader.getTitle(toneSettings[fileProperty])
        }
        return displayTitle
    }

    label: defaultText
    title: getTitle()
    toneEnabled: toneSettings[enabledProperty]
    value: (title != "" && toneEnabled)
           ? title
             //% "No sound"
           : qsTrId("jolla-gallery-ambience-sound-la-no-alarm-sound")

    onClicked: {
        var dialog = pageStack.push(dialogComponent, {
                        activeFilename: toneSettings[fileProperty],
                        activeSoundTitle: title,
                        activeSoundSubtitle: currentText,
                        noSound: !toneSettings[enabledProperty]
                        })

        dialog.accepted.connect(
            function() {
                if (dialog.selectedFilename != "" && dialog.selectedFilename != toneSettings[fileProperty]) {
                    toneSettings[fileProperty] = dialog.selectedFilename
                    toneSettings[displayNameProperty] = ""
                }
                toneSettings[enabledProperty] = !dialog.noSound
            })
     }
}
