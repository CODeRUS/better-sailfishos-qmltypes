import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import Sailfish.Gallery 1.0
import Sailfish.Ambience 1.0
import com.jolla.gallery 1.0
import com.jolla.gallery.ambience 1.0
import org.nemomobile.thumbnailer 1.0
import QtGraphicalEffects 1.0

Page {
    id: root
    property AmbienceModel favesModel: AmbienceModel { filter: AmbienceModel.FavoritesOnly }
    property AmbienceModel ambienceModel
    property url source

    property int _listWidth: root.isPortrait ? Screen.width : Screen.height - (Screen.width / 2)
    property bool _minimized:  !Qt.application.active

    // Helper properties to decide what combination should be shown and enabled/disabled
    // Max favorite count is 18
    property bool _favesLeft: favesModel.count < 18
    property bool _showHelpLabel: _favesLeft && !ambience.favorite
    property bool _showMaxFavesLabel: !_favesLeft && !ambience.favorite
    property bool _showFaveButton: (ambience.favorite && !_favesLeft) || _favesLeft

    allowedOrientations: window.allowedOrientations

    // Save only when user leaves the app or goes back to the previous page
    onStatusChanged: {
        if (status === PageStatus.Deactivating && !removeRemorse.visible) {
            ambience.save()
        }
    }

    on_MinimizedChanged: {
        if (_minimized) {
            ambience.save()
        }
    }

    onSourceChanged: {
        ambience.init()
    }

    // Update the Cover via window.activeObject property
    Binding {
        target: window
        property: "activeObject"
        value: root.status === PageStatus.Active
               ? { url: ambience.wallpaperUrl, mimeType: ambience.mimeType }
               : { url: "", mimeType: ""}
    }

    // There's no view and delegate so ambience object is used
    // for wrapping model specific operations into an object.
    QtObject {
        id: ambience

        // Read-only properties
        property url source
        property url wallpaperUrl
        property bool readOnly
        property string mimeType
        property string tohId

        // Read and write properties
        property bool favorite
        property string displayName

        property bool _initDone
        property bool _modified
        property bool _removed

        onFavoriteChanged: ambience.setModified()
        onDisplayNameChanged: ambience.setModified()

        function index()
        {
            var index = -1
            if (!ambienceModel) {
                return index
            }

            for (var i=0; i < ambienceModel.count; ++i) {
                var item = ambienceModel.get(i)
                if (item.url == root.source) {
                    index = i
                    break
                }
            }

            return index
        }

        function init()
        {
            if (_initDone) {
                return
            }

            var _index = index()

            if (_index < 0) {
                return
            }

            var obj = ambienceModel.get(_index)

            source          = obj.url
            wallpaperUrl    = obj.wallpaperUrl
            mimeType        = obj.mimeType
            tohId           = obj.tohId
            favorite        = obj.favorite
            displayName     = obj.displayName
            readOnly        = obj.readOnly

            ambienceName.text = displayName

            // If ringerToneFile is set, then we know it has been saved once
            // and we can read resource and other properties from the obj.
            if (obj.resources.ringerToneFile === undefined) {
                ambienceProfile.initWithDefaultValues()
            } else {
                ambienceProfile.initWithModifiedValues(obj)
            }

            // Setup colors which user can edit
            ambienceColors.initColors(obj)

            _initDone = true
        }

        function setModified()
        {
            if (_initDone && !_modified) {
                _modified = true
            }
        }

        function makeCurrent()
        {
            if (ambience._modified) {
                save()
            }

            ambienceModel.makeCurrent(ambience.index())
        }

        function remove()
        {
            _removed = true
            ambienceModel.remove(ambience.index())
        }

        function save()
        {
            if (!ambience._initDone || !ambience._modified || ambience._removed) {
                return
            }

            ambienceModel.set(ambience.index(), {
            favorite:                   favorite,
            displayName:                displayName,

            // Volume
            ringerVolume:               ambienceProfile.ringerVolume,

            // Sound enablers
            ringerToneEnabled:          ambienceProfile.ringerToneEnabled,
            messageToneEnabled:         ambienceProfile.messageToneEnabled,
            mailToneEnabled:            ambienceProfile.mailToneEnabled,
            internetCallToneEnabled:    ambienceProfile.internetCallToneEnabled,
            chatToneEnabled:            ambienceProfile.chatToneEnabled,
            calendarToneEnabled:        ambienceProfile.calendarToneEnabled,
            clockAlarmToneEnabled:      ambienceProfile.clockAlarmToneEnabled,

            // Sound files
            ringerToneFileUrl:          ambienceProfile.ringerToneFile,
            messageToneFileUrl:         ambienceProfile.messageToneFile,
            mailToneFileUrl:            ambienceProfile.mailToneFile,
            internetCallToneFileUrl:    ambienceProfile.internetCallToneFile,
            chatToneFileUrl:            ambienceProfile.chatToneFile,
            calendarToneFileUrl:        ambienceProfile.calendarToneFile,
            clockAlarmToneFileUrl:      ambienceProfile.clockAlarmToneFile,

            // Colors
            highlightColor:             ambienceColors.highlightColor
            })

            // Reload ambience if it's the current one
            if (Ambience.homeWallpaper === wallpaperUrl) {
                ambienceModel.makeCurrent(ambience.index())
            }

            ambience._modified = false
        }
    }

    // Copy default values for new ambience from Profile
    Profile {
        id: profileControl
        profile: Profile.General
    }

    // This mimics ProfileControl object and we can pass this directly
    // to the Tones QML element
    QtObject {
        id: ambienceProfile

        property int ringerVolume

        property string ringerToneFile
        property string ringerToneFileDisplayName

        property string messageToneFile
        property string messageToneFileDisplayName

        property string chatToneFile
        property string chatToneFileDisplayName

        property string mailToneFile
        property string mailToneFileDisplayName

        property string internetCallToneFile
        property string internetCallToneFileDisplayName

        property string calendarToneFile
        property string calendarToneFileDisplayName

        property string clockAlarmToneFile
        property string clockAlarmToneFileDisplayName

        property bool ringerToneEnabled
        property bool messageToneEnabled
        property bool chatToneEnabled
        property bool mailToneEnabled
        property bool internetCallToneEnabled
        property bool calendarToneEnabled
        property bool clockAlarmToneEnabled

        onRingerVolumeChanged:              ambience.setModified()
        onRingerToneFileChanged:            ambience.setModified()
        onRingerToneEnabledChanged:         ambience.setModified()
        onMessageToneFileChanged:           ambience.setModified()
        onMessageToneEnabledChanged:        ambience.setModified()
        onChatToneFileChanged:              ambience.setModified()
        onChatToneEnabledChanged:           ambience.setModified()
        onMailToneFileChanged:              ambience.setModified()
        onMailToneEnabledChanged:           ambience.setModified()
        onInternetCallToneFileChanged:      ambience.setModified()
        onInternetCallToneEnabledChanged:   ambience.setModified()
        onCalendarToneFileChanged:          ambience.setModified()
        onCalendarToneEnabledChanged:       ambience.setModified()
        onClockAlarmToneFileChanged:        ambience.setModified()
        onClockAlarmToneEnabledChanged:     ambience.setModified()

        function initWithDefaultValues()
        {
            // First time use, copy bunch of default profile properties to this object
            for (var key in profileControl) {
                if (typeof profileControl[key] !== "function"
                    && ambienceProfile.hasOwnProperty(key)) {
                    ambienceProfile[key] = profileControl[key]
                }
            }
        }

        function initWithModifiedValues(obj)
        {
            // These values come from the database
            ringerVolume                = obj.ringerVolume

            ringerToneEnabled       = obj.ringerToneEnabled
            messageToneEnabled      = obj.messageToneEnabled
            chatToneEnabled         = obj.chatToneEnabled
            mailToneEnabled         = obj.mailToneEnabled
            internetCallToneEnabled = obj.internetCallToneEnabled
            calendarToneEnabled     = obj.calendarToneEnabled
            clockAlarmToneEnabled   = obj.clockAlarmToneEnabled

            // Ringtones and if not set, fallback to the default value
            var audioFiles = obj.resources

            if (audioFiles.ringerToneFile) {
                ringerToneFile = audioFiles.ringerToneFile.url
                ringerToneFileDisplayName = audioFiles.ringerToneFile.displayName
            } else {
                ringerToneFile = profileControl.ringerToneFile
                ringerToneFileDisplayName = ""
            }

            if (audioFiles.messageToneFile) {
                messageToneFile = audioFiles.messageToneFile.url
                messageToneFileDisplayName = audioFiles.messageToneFile.displayName
            } else {
                messageToneFile = profileControl.messageToneFile
                messageToneFileDisplayName = ""
            }

            if (audioFiles.chatToneFile) {
                chatToneFile = audioFiles.chatToneFile.url
                chatToneFileDisplayName = audioFiles.chatToneFile.displayName
            } else {
                chatToneFile = profileControl.messageToneFile
                chatToneFileDisplayName = ""
            }

            if (audioFiles.mailToneFile) {
                mailToneFile = audioFiles.mailToneFile.url
                mailToneFileDisplayName = audioFiles.mailToneFile.displayName
            } else {
                mailToneFile = profileControl.messageToneFile
                mailToneFileDisplayName = ""
            }

            if (audioFiles.internetCallToneFile) {
                internetCallToneFile = audioFiles.internetCallToneFile.url
                internetCallToneFileDisplayName = audioFiles.internetCallToneFile.displayName
            } else {
                internetCallToneFile = profileControl.internetCallToneFile
                internetCallToneFileDisplayName = ""
            }

            if (audioFiles.calendarToneFile) {
                calendarToneFile = audioFiles.calendarToneFile.url
                calendarToneFileDisplayName = audioFiles.calendarToneFile.displayName
            } else {
                calendarToneFile = profileControl.calendarToneFile
                calendarToneFileDisplayName = ""
            }

            if (audioFiles.clockAlarmToneFile) {
                clockAlarmToneFile = audioFiles.clockAlarmToneFile.url
                clockAlarmToneFileDisplayName = audioFiles.clockAlarmToneFile.displayName
            } else {
                clockAlarmToneFile = profileControl.clockAlarmToneFile
                clockAlarmToneFileDisplayName = ""
            }
        }
    }

    QtObject {
        id: ambienceColors

        property color highlightColor

        onHighlightColorChanged: ambience.setModified()

        function initColors(obj)
        {
            ambienceColors.highlightColor = obj.highlightColor
        }
    }

    RemorsePopup { id: removeRemorse }

    SilicaFlickable {
        id: contentList

        anchors.fill: parent
        contentHeight: root.isPortrait
                       ? ambience.favorite ? image.height + settingsList.implicitHeight + Theme.paddingLarge : root.height
                       : ambience.favorite ? settingsList.implicitHeight + Theme.paddingLarge : root.height

        PullDownMenu {
            highlightColor: ambienceColors.highlightColor

            // TODO: Usually this is darker version of major color, not highlight color
            backgroundColor: Qt.darker(ambienceColors.highlightColor, 125)

            z: image.z + 1

            MenuItem {
                //: Remove ambience from the ambience list
                //% "Remove ambience"
                text: qsTrId("jolla-gallery-ambience-me-remove_ambience")
                color: down || highlighted ? Theme.primaryColor : ambienceColors.highlightColor
                onClicked: {
                    //: Remorse popup text for ambience deletion
                    //% "Deleting Ambience"
                    removeRemorse.execute(qsTrId("jolla-gallery-ambience-delete-ambience"),
                                          function() {
                                              ambience.remove()
                                              pageStack.pop()
                                          })
                }
            }
            MenuItem {
                //: Active the ambience
                //% "Set Ambience"
                text: qsTrId("jolla-gallery-ambience-me-set_ambience")
                color: down || highlighted ? Theme.primaryColor : ambienceColors.highlightColor
                onClicked: ambience.makeCurrent()
            }
        }

        Thumbnail {
            id: image
            sourceSize.width: Screen.width
            sourceSize.height: Theme.itemSizeLarge * 3 + Theme.paddingMedium
            width: root.isPortrait ? sourceSize.width : Screen.width / 2
            height: root.isPortrait ? sourceSize.height : Screen.width / 2
            source: ambience.wallpaperUrl
        }

        OpacityRampEffect {
            sourceItem: image
            offset: 0.5
            slope: 2.0
            direction: OpacityRamp.BottomToTop
        }

        Image {
            id: faveButton

            property url selectedIconUrl: "image://theme/icon-m-favorite-selected"
            property url unselectedIconUrl:"image://theme/icon-m-favorite"

            source: ambience.favorite ? selectedIconUrl : unselectedIconUrl
            opacity: _showFaveButton ? 1 : 0
            anchors {
                right: image.right
                bottom: image.bottom
                bottomMargin: Theme.paddingMedium
                rightMargin: (root.isPortrait ? Theme.horizontalPageMargin : Theme.paddingLarge) - Theme.paddingMedium
            }

            MouseArea {
                anchors.fill: parent
                enabled: _showFaveButton
                onClicked: {
                    ambience.favorite = !ambience.favorite
                }
            }
        }


        // Handle editor expanding so that editor content will be always pushed up to
        // make them visible.
        Connections {
            target: settingsList.currentEditor
            onHeightChanged: {
                var editorStart = settingsList.currentEditor.mapToItem(contentList.contentItem, 0, 0).y
                var editorEnd = editorStart + settingsList.currentEditor.height

                if ((contentList.contentY + contentList.height) < editorEnd) {
                    contentList.contentY = Math.max(contentList.contentY, Math.min(editorStart, editorEnd - contentList.height))
                }
            }
        }

        Column {
            id: settingsList

            property Item currentEditor

            function setCurrentEditor(editor)
            {
                if (currentEditor == editor) {
                    currentEditor = null
                } else {
                    currentEditor = editor
                }
            }

            anchors {
                left: root.isPortrait ? image.left : image.right
                top: root.isPortrait ? image.bottom : parent.top
                topMargin: Theme.paddingLarge
                right: parent.right
            }
            opacity: 1.0 - (helpLabel.opacity * 2)
            visible: opacity > 0.0 // disables the controls when opacity == 0.0

            TextField {
                id: ambienceName

                width: root._listWidth
                horizontalAlignment: TextInput.AlignLeft
                textLeftMargin: root.isPortrait ? Theme.horizontalPageMargin : Theme.paddingLarge

                //: Write a name label for ambience in read-only mode
                //% "Ambience name"
                label: qsTrId("jolla-gallery-ambience-la-ambience-name")

                //: Placeholder text for the write a name text field
                //% "Ambience name"
                placeholderText: qsTrId("jolla-gallery-ambience-ph_write_name")
                onTextChanged: ambience.displayName = text
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    root.focus = true
                }
            }

            EditorItem {
                id: colorEditor

                //: Modify ambience appearance
                //% "Appearance"
                text: qsTrId("jolla-gallery-ambience-la-appearance")
                onEditorItemClicked: settingsList.setCurrentEditor(colorEditor)
                active: settingsList.currentEditor == colorEditor
                width: root._listWidth

                AmbienceColorEditor {
                    colorSettings: ambienceColors
                    activeAmbience: Ambience.homeWallpaper === ambienceModel.get(ambience.index()).wallpaperUrl
                    width: root._listWidth
                    leftMargin: root.isPortrait
                                ? Math.round(Screen.width / 8)
                                : Theme.paddingLarge
                }

                Item { width: 1; height: Theme.paddingMedium }
            }

            EditorItem {
                id: soundsEditor

                onEditorItemClicked: settingsList.setCurrentEditor(soundsEditor)
                active: settingsList.currentEditor == soundsEditor
                width: root._listWidth
                //: Modify ambience sounds
                //% "Sounds
                text: qsTrId("jolla-gallery-ambience-la-sounds")
                Slider {
                    // "Ambience specific ringtone volume"
                    //% "Ringtone volume"
                    label: qsTrId("jolla-gallery-ambience-la-ringtone-volume")
                    width: root._listWidth
                    minimumValue: 1
                    maximumValue: 100
                    value: ambienceProfile.ringerVolume < 0
                           ? profileControl.ringerVolume
                           : ambienceProfile.ringerVolume
                    onValueChanged: ambienceProfile.ringerVolume = value
                    leftMargin: root.isPortrait
                                ? Math.round(Screen.width / 8)
                                : Theme.paddingLarge
                }

                Tones {
                    toneSettings: ambienceProfile
                }
            }

            Label {
                id: editHelpLabel
                //: Help text to instruct how to reset back to original ambience setup
                //% "You can reset back to the original settings by reinstalling the ambience."
                text: qsTrId("jolla-gallery-ambience-la-edit-help-text")
                width: root._listWidth - 2 * Theme.paddingLarge
                opacity: (ambience.readOnly && ambience.tohId !== "") ? 1.0 : 0.0
                Behavior on opacity { FadeAnimation {} }
                wrapMode: Text.Wrap
                x: Theme.paddingLarge
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                visible: opacity == 1
            }

            // Spacer item at the bottom
            Item {
                width: 1
                height: Theme.paddingLarge
            }
        }

        VerticalScrollDecorator {}
    }


    // Label for different informative help texts
    Label {
        id: helpLabel
        //: Help text for accessing ambience via homescreen
        //% "Set your Ambience as favorite and access it with push gesture from Homescreen."
        property string helpText: qsTrId("jolla-gallery-ambience-la-help-text")

        //: Maximum amount of favorite ambiences reached
        //% "You have reached maximum amount of favorite Ambiences. Unfavorite the old to have new ones."
        property string maxFavesText: qsTrId("jolla-gallery-ambience-la-max-favorites-reached")

        opacity: root._showHelpLabel || root._showMaxFavesLabel ? 0.5 : 0
        onOpacityChanged: if (opacity == 0) text == ""
        Behavior on opacity { FadeAnimation {} }

        text: root._showHelpLabel
              ? helpText : root._showMaxFavesLabel
              ? maxFavesText : ""
        color: ambienceColors.highlightColor

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        height: parent.height - image.height
        width: parent.width - 2 * Theme.paddingLarge
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }
    }
}
