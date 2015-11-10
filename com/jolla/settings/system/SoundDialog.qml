import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import QtMultimedia 5.0

Dialog {
    id: soundDialog

    property string activeFilename
    property string activeSoundTitle
    property string activeSoundSubtitle
    property bool noSound
    property string selectedFilename: activeFilename
    property string selectedSoundTitle: activeSoundTitle
    property QtObject alarmModel

    onSelectedFilenameChanged: previewPlayer.source = selectedFilename
    onActiveFilenameChanged: previewPlayer.source = activeFilename

    canAccept: selectedFilename != "" || noSound

    PreviewPlayer {
        id: previewPlayer
    }

    Component {
        id: musicPicker

        MultiMusicPickerDialog {
            preview: true

            onSelectedContentChanged: {
                // Only preview here
                if (selectedContent.count == 1) {
                    var content = selectedContent.get(0)
                    soundDialog.selectedFilename = content.filePath
                    soundDialog.selectedSoundTitle = content.title
                    alarmToneList.currentIndex = -1
                } else {
                    soundDialog.selectedFilename = ""
                    soundDialog.selectedSoundTitle = ""
                }
                previewPlayer.toggle(soundDialog.selectedFilename)
            }
            onAccepted: soundDialog.accepted()
            onRejected: {
                if (previewPlayer.playbackState == Audio.PlayingState) {
                    previewPlayer.stop()
                }
            }
        }
    }

    SilicaListView {
        id: alarmToneList

        anchors.fill: parent
        currentIndex: -1
        header: Column {
            width: parent.width

            DialogHeader {
                dialog: soundDialog
            }

            AudioItem {
                height: Theme.itemSizeMedium
                title: soundDialog.activeSoundTitle
                subtitle: soundDialog.activeSoundSubtitle
                icon: "image://theme/icon-m-pause"
                iconOpacity: alarmToneList.currentIndex == -1 && previewPlayer.playbackState === Audio.PlayingState
                             ? 1.0 : 0.0
                enabled: !noSound
                visible: soundDialog.activeFilename != ""

                onClicked: {
                    alarmToneList.currentIndex = -1
                    soundDialog.selectedFilename = soundDialog.activeFilename
                    soundDialog.selectedSoundTitle = soundDialog.activeSoundTitle
                    previewPlayer.toggle(soundDialog.selectedFilename)
                }
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }
            BackgroundItem {
                id: selectFromMusic

                width: parent.width
                enabled: !noSound
                opacity: enabled ? 1.0 : 0.5
                onClicked: pageStack.push(musicPicker, {
                                                    acceptDestination: soundDialog.acceptDestination
                                                                || pageStack.previousPage(soundDialog),
                                                    acceptDestinationAction: PageStackAction.Pop
                                                })

                Image {
                    id: musicIcon
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    source: "image://theme/icon-m-sounds" + (selectFromMusic.down ? ("?" + Theme.highlightColor)
                                                                                  : "")
                }

                Label {
                    anchors.left: musicIcon.right
                    anchors.right: parent.right
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.rightMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    color: selectFromMusic.down ? Theme.highlightColor : Theme.primaryColor
                    //% "Select from music"
                    text: qsTrId("settings_sound-la-select_from_music")
                }
            }

            TextSwitch {
                //% "No sound"
                text: qsTrId("settings_sound-la-no_sound")

                checked: noSound
                onCheckedChanged: {
                    noSound = checked
                    if (noSound) {
                        alarmToneList.currentIndex = -1
                        soundDialog.selectedFilename = ""
                        soundDialog.selectedSoundTitle = ""
                        previewPlayer.stop()
                    }
                }
                leftMargin: Theme.horizontalPageMargin - Theme.paddingMedium
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }
        }

        model: alarmModel
        delegate: AudioItem {
            id: alarmDelegate
            title: {
                var suffixPos = fileName.lastIndexOf('.')
                var baseName = suffixPos > 0 ? fileName.substring(0, suffixPos) : fileName
                return baseName.replace(/_/g, ' ')
            }

            icon: "image://theme/icon-m-pause"
            iconOpacity: previewPlayer.playbackState === Audio.PlayingState && alarmToneList.currentIndex == index
                         ? 1.0 : 0.0
            selected: alarmToneList.currentIndex == index
            enabled: !noSound
            onClicked: {
                alarmToneList.currentIndex = index
                soundDialog.selectedFilename = filePath
                soundDialog.selectedSoundTitle = alarmDelegate.title
                previewPlayer.toggle(soundDialog.selectedFilename)
            }
        }
        VerticalScrollDecorator {}
    }
}
