import QtQuick 2.0
import QtQml.Models 2.1
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Ambience 1.0
import com.jolla.gallery.ambience 1.0
import org.nemomobile.thumbnailer 1.0
import org.freedesktop.contextkit 1.0

Page {
    id: root

    property int _listWidth: root.isPortrait ? Screen.width : Screen.height - (Screen.width / 2)
    property bool _minimized:  !Qt.application.active
    property alias contentId: ambience.contentId
    property alias source: ambience.url
    property alias ambience: ambience
    property bool allowRemove: Ambience.source != ambience.url
    readonly property bool wasRemoved: _removed || removeRemorse.visible
    property bool _removed
    property color _originalHighlightColor
    property color _originalSecondaryHighlightColor
    property bool _colorChanged
    property bool _completed
    property bool _hasDataCapability: capabilityDataContextProperty.value || capabilityDataContextProperty.value === undefined
    property bool _hasVoiceCapability: capabilityVoiceContextProperty.value || capabilityVoiceContextProperty.value === undefined

    signal ambienceRemoved()

    allowedOrientations: Orientation.All

    // Save only when user leaves the app or goes back to the previous page
    onStatusChanged: {
        if (status === PageStatus.Deactivating && !wasRemoved) {
            ambience.commitChanges()
        } else if (status === PageStatus.Inactive) {
            contentList.positionViewAtBeginning()
        }
    }

    on_MinimizedChanged: {
        if (_minimized) {
            ambience.commitChanges()
        }
    }

    on_HasDataCapabilityChanged: {
        ambience.changed()
    }

    on_HasVoiceCapabilityChanged: {
        ambience.changed()
    }

    function _unSupportedAction(prop) {
        if (prop == "ringerTone" && !_hasVoiceCapability) {
            return true
        } else if (prop == "messageTone" && !_hasDataCapability) {
            return true
        }
        return false
    }

    ContextProperty {
        id: capabilityVoiceContextProperty
        key: "Cellular.CapabilityVoice"
    }

    ContextProperty {
        id: capabilityDataContextProperty
        key: "Cellular.CapabilityData"
    }

    AmbienceActions {
        id: ambienceActions
    }

    AmbienceInfo {
        id: ambience

        property alias actions: actionsModel

        function commitChanges() {
            save()
        }

        ListModel {
            id: actionsModel
            dynamicRoles: true
        }

        ListModel {
            id: availableActionsModel
        }

        onChanged: {
            if (!root._completed) {
                root._completed = true
                root._originalHighlightColor = highlightColor
                root._originalSecondaryHighlightColor = secondaryHighlightColor
            }
            var j = 0
            var k = 0
            for (var i = 0; i < ambienceActions.properties.length; ++i) {
                var property = ambienceActions.properties[i]
                var action = ambienceActions[property]
                if (action.hasValue(ambience)) {
                    if (j == actionsModel.count || actionsModel.get(j).property != property) {
                        actionsModel.insert(j, {
                            "section": action.section,
                            "property": property,
                            "label": action.label
                        })
                    }
                    ++j
                    if (k < availableActionsModel.count
                                && availableActionsModel.get(k).property == property) {
                        availableActionsModel.remove(k)
                    }
                } else {
                    if (j < actionsModel.count && actionsModel.get(j).property == property) {
                        actionsModel.remove(j)
                    }
                    if (k == availableActionsModel.count
                                || availableActionsModel.get(k).property != property) {
                        availableActionsModel.insert(k, {
                            "section": action.section,
                            "property": property,
                            "label": action.label,
                        })
                    }
                    ++k
                }
            }
            if (j == actionsModel.count) {
                actionsModel.append({ section: "", property: "", label: "", value: "" })
            }
            // Remove any possible not supported property from the availableActionsModel,
            // note that we dont touch actionModel, since supported actions can change later
            // and above code will add these properties again
            for (var iter = 0; iter < availableActionsModel.count; ++iter) {
                var prop = availableActionsModel.get(iter).property
                if (prop && _unSupportedAction(prop)) {
                    availableActionsModel.remove(iter)
                }
            }

            if (ambience.applicationWallpaperUrl == "") {
                Ambience.create(ambience.url)
            }
        }
    }

    RemorsePopup { id: removeRemorse }

    SilicaListView {
        id: contentList

        anchors.fill: parent

        PullDownMenu {
            highlightColor: ambience.highlightColor
            backgroundColor: Ambience.highlightBackgroundColor(ambience.highlightColor)

            MenuItem {
                enabled: root.allowRemove
                //: Remove ambience from the ambience list
                //% "Remove ambience"
                text: qsTrId("jolla-gallery-ambience-me-remove_ambience")
                color: down || highlighted ? Theme.primaryColor : ambience.highlightColor
                onClicked: {
                    //: Remorse popup text for ambience deletion
                    //% "Deleting Ambience"
                    removeRemorse.execute(qsTrId("jolla-gallery-ambience-delete-ambience"),
                                          function() {
                                              root._removed = true
                                              root.ambienceRemoved()
                                              ambience.remove()
                                              pageStack.pop()
                                          })
                }
            }
            MenuItem {
                //: Active the ambience
                //% "Set Ambience"
                text: qsTrId("jolla-gallery-ambience-me-set_ambience")
                color: down || highlighted ? Theme.primaryColor : ambience.highlightColor
                visible: Ambience.source != ambience.url
                onClicked: {
                    ambience.save()
                    Ambience.source = ambience.url
                }
            }
        }

        header: Column {
            id: settingsList
            width: contentList.width

            Item {
                width: contentList.width
                height: 2 * (Screen.sizeCategory >= Screen.Large
                        ? Theme.itemSizeExtraLarge + (2 * Theme.paddingLarge)
                        : Screen.height / 5)

                Image {
                    id: image
                    anchors.fill: parent
                    source: ambience.wallpaperUrl
                    fillMode: Image.PreserveAspectCrop
                }

                OpacityRampEffect {
                    offset: 0.5
                    slope: 2.0
                    direction: OpacityRamp.BottomToTop
                    sourceItem: image
                }
            }

            MouseArea {
                id: highlightColorReset

                width: contentList.width
                height: Theme.itemSizeLarge

                clip: true
                enabled: root._colorChanged
                onClicked: {
                    ambience.highlightColor = root._originalHighlightColor
                    ambience.secondaryHighlightColor = root._originalSecondaryHighlightColor
                    highlightSlider.hue = Color.hue(ambience.highlightColor)
                    root._colorChanged = false
                }

                Wallpaper {
                    id: wallpaper
                    anchors.fill: highlightColorReset
                    verticalOffset: (Screen.height + image.height) / 2
                    source: ambience.applicationWallpaperUrl

                    windowRotation: root.rotation
                }

                ShaderEffect {
                    id: dot

                    x: Theme.horizontalPageMargin
                    width: dotImage.width
                    height: dotImage.height
                    anchors.verticalCenter: highlightColorReset.verticalCenter

                    property color color: highlightColorReset.pressed
                            ? root._originalHighlightColor
                            : ambience.highlightColor
                    property Image source: Image {
                        id: dotImage
                        source: "image://theme/icon-m-dot"
                    }

                    fragmentShader: "
                        varying highp vec2 qt_TexCoord0;
                        uniform sampler2D source;
                        uniform lowp vec4 color;
                        uniform lowp float qt_Opacity;

                        void main() {
                            lowp vec4 tex = texture2D(source, qt_TexCoord0);
                            gl_FragColor = color * tex.a * qt_Opacity;
                        }"
                }

                Label {
                    id: colorLabel
                    anchors {
                        left: dot.right
                        leftMargin: Theme.paddingMedium
                        verticalCenter: highlightColorReset.verticalCenter
                    }

                    //: Text to indicate color changes
                    //% "Ambience color"
                    text: qsTrId("jolla-gallery-ambience-la-ambience-color")
                    color: Theme.rgba(
                                highlightColorReset.pressed
                                    ? root._originalHighlightColor
                                    : ambience.highlightColor,
                                0.7)

                    states: State {
                        when: highlightColorReset.enabled
                        AnchorChanges {
                            target: colorLabel
                            anchors {
                                baseline: highlightColorReset.verticalCenter
                                verticalCenter: undefined
                            }
                        }
                        PropertyChanges {
                            target: resetLabel
                            opacity: 1
                        }
                    }

                    transitions: [
                        Transition {
                            AnchorAnimation { duration: 100 }
                            FadeAnimation { target: resetLabel; duration: 100 }
                        }
                    ]
                }

                Label {
                    id: resetLabel
                    anchors {
                        left: dot.right
                        leftMargin: Theme.paddingMedium
                        top: colorLabel.bottom
                    }
                    //: Text to indicate color changes
                    //% "Tap to reset"
                    text: qsTrId("jolla-gallery-ambience-la-reset-color")
                    color: Theme.rgba(
                                highlightColorReset.pressed
                                    ? root._originalHighlightColor
                                    : Theme.primaryColor,
                                0.7)
                    font.pixelSize: Theme.fontSizeSmall
                    opacity: 0
                }

            }

            ColorSlider {
                id: highlightSlider
                minimumValue: 0
                maximumValue: 1
                stepSize: 0.01
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Theme.paddingLarge

                //: Highlight color for ambience
                //% "Ambience color"
                label: qsTrId("jolla-gallery-ambience-la-ambience-color")

                onHueChanged: {
                    if (enabled) {
                        root._colorChanged = true
                        ambience.highlightColor = Color.toHighlight(Color.fromHsva(hue, 1.0, 0.5, 1.0))
                        ambience.secondaryHighlightColor = Qt.darker(ambience.highlightColor, 1.25)
                    }
                }

                Connections {
                    target: ambience
                    onChanged: {
                        highlightSlider.enabled = false
                        highlightSlider.hue = Color.hue(ambience.highlightColor)
                        highlightSlider.enabled = true
                    }
                }
            }

            TextField {
                id: ambienceName

                width: root._listWidth
                horizontalAlignment: TextInput.AlignLeft
                textLeftMargin: Theme.horizontalPageMargin

                //: Write a name label for ambience in read-only mode
                //% "Ambience name"
                label: qsTrId("jolla-gallery-ambience-la-ambience-name")

                //: Placeholder text for the write a name text field
                //% "Ambience name"
                placeholderText: qsTrId("jolla-gallery-ambience-ph_write_name")
                text: ambience.displayName
                onTextChanged: ambience.displayName = text
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    root.focus = true
                }
            }

            MouseArea {
                id: favoriteButton

                property bool down: pressed && containsMouse

                width: contentList.width
                height: Theme.itemSizeLarge
                onClicked: {
                    ambience.favorite = !ambience.favorite
                }

                Image {
                    id: favoriteIcon

                    x: Theme.horizontalPageMargin
                    source: (ambience.favorite ? "image://theme/icon-m-favorite-selected?" : "image://theme/icon-m-favorite?")
                            + (favoriteButton.down ? Theme.highlightColor : Theme.primaryColor)
                    anchors.verticalCenter: favoriteButton.verticalCenter
                }

                Label {
                    anchors {
                        left: favoriteIcon.right
                        right: favoriteButton.right
                        verticalCenter: favoriteButton.verticalCenter
                        margins: Theme.paddingMedium
                    }

                    //% "Show in Top menu"
                    text: qsTrId("jolla-gallery-ambience-la-show-in-top-menu")
                    color: favoriteButton.down ? Theme.highlightColor : Theme.primaryColor
                }
            }

            SectionHeader {
                //% "Actions"
                text: qsTrId("jolla-gallery-ambience-la-actions")
            }
            Label {
                anchors {
                    left: settingsList.left
                    right: settingsList.right
                    margins: Theme.horizontalPageMargin
                }

                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                color: Theme.highlightColor

                //% "You can define a set of actions to trigger when this ambience is selected"
                text: qsTrId("jolla-gallery-ambience-la-actions-explanation")
            }
        }

        model: ambience.actions
        delegate: Item {
            id: actionButton

            function expand() {
                if (loader.item && loader.item.expand !== undefined) {
                    loader.item.expand()
                }
            }

            width: contentList.width
            height: loader.height

            visible: model.property != ""

            ListView.delayRemove: removeAnimation.running
            ListView.onRemove: removeAnimation.start()
            SequentialAnimation {
                id: removeAnimation
                running: false
                FadeAnimation { target: actionButton; to: 0; duration: 200 }
                NumberAnimation { target: actionButton; properties: "height"; to: 0; duration: 200; easing.type: Easing.InOutQuad }
            }

            Loader {
                id: loader

                width: contentList.width
                sourceComponent: model.property != "" ? ambienceActions[model.property].editor  : null
            }

            IconButton {
                anchors {
                    right: actionButton.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: actionButton.top
                    verticalCenterOffset: Theme.itemSizeSmall / 2
                }

                icon.source: "image://theme/icon-m-clear"

                onClicked: {
                    ambienceActions[model.property].clearValue(ambience)
                    ambience.changed()
                }
            }
        }

        footer: ListButton {
            //% "Add actions"
            text: qsTrId("jolla-gallery-ambience-la-add-actions")
            icon.source: "image://theme/icon-m-add"
            enabled: availableActionsModel.count > 0

            onClicked: pageStack.push(addActionsPage)
        }

        VerticalScrollDecorator {}
    }

    Component {
        id: addActionsPage
        Page {
            id: page

            SilicaListView {
                id: listView

                anchors.fill: parent

                model: availableActionsModel

                header: PageHeader {
                    //% "Select action"
                    title: qsTrId("jolla-gallery-ambience-he-select action")
                }
                section {
                    property: "section"
                    delegate: SectionHeader {
                        text: section
                    }
                }
                delegate: ListButton {
                    text: label
                    onClicked: {
                        var action = ambienceActions[property]
                        if (action.dialog) {
                            pageStack.push(action.dialog, {
                                "ambience": ambience,
                                "acceptDestination": root,
                                "acceptDestinationAction": PageStackAction.Pop
                            })
                        } else {
                            ListView.delayRemove = true
                            if (!action.hasValue(ambience)) {
                                action.setDefaultValue(ambience)
                                ambience.changed()
                            }
                            pageStack.pop(root)
                            for (var i = 0; i < actionsModel.count; ++i) {
                                if (actionsModel.get(i).property == action.property) {
                                    contentList.positionViewAtIndex(i, ListView.Contain)
                                    break
                                }
                            }
                            for (i = 0; i < contentList.contentItem.children.length; ++i) {
                                var item = contentList.contentItem.children[i]
                                if (item.property == action.property) {
                                    item.expand()
                                    break;
                                }
                            }
                        }
                    }
                }

                VerticalScrollDecorator {}
            }
        }
    }
}
