import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Ambience 1.0
import Sailfish.Media 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0

AmbienceAction {
    id: action

    property string currentText
    readonly property string enabledProperty: property + "Enabled"
    readonly property string fileProperty: property + "File"
    readonly property QtObject tone: ambience.resources[action.fileProperty]
    property string title: {
        if (ambience[enabledProperty]) {
            var displayName = ambience.resources[fileProperty].displayName
            if (displayName.length > 0) {
                return displayName
            }
            return metadataReader.getTitle(tone.url)
        } else {
            //% "No sound"
            return qsTrId("jolla-gallery-ambience-sound-la-no-alarm-sound")
        }
    }

    function hasValue(ambience) {
        return !ambience[enabledProperty] || ambience.resources[fileProperty].url != ""
    }
    function clearValue(ambience) {
        ambience[enabledProperty] = true
        ambience.resources[fileProperty].url = ""
    }

    property list<QtObject> _resources: [
        MetadataReader {
            id: metadataReader
        }
    ]

    editor: ValueButton {
        id: toneEditor

        label: action.label
        value: action.title

        rightMargin: Theme.horizontalPageMargin + Theme.itemSizeSmall + Theme.paddingMedium

        onClicked: pageStack.push(dialog)
    }

    dialog: Component {
        id: soundDialog

        SoundDialog {
            activeFilename: tone.url
            activeSoundTitle: action.title
            activeSoundSubtitle: action.currentText
            noSound: !ambience[action.enabledProperty]

            alarmModel: ToneModel {}

            onAccepted: {
                ambience[action.enabledProperty] = !noSound
                tone.url = selectedFilename
                ambience.save()
            }
        }
    }

}
