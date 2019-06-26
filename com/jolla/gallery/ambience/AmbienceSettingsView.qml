import QtQuick 2.3
import QtQml.Models 2.1
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as SilicaPrivate
import Sailfish.Gallery 1.0
import Sailfish.Ambience 1.0
import com.jolla.gallery.ambience 1.0
import org.nemomobile.thumbnailer 1.0
import org.freedesktop.contextkit 1.0
import org.nemomobile.configuration 1.0

SilicaFlickable {
    id: root

    property color primaryColor: Theme.primaryColor
    property color secondaryColor: Theme.secondaryColor
    property color highlightColor: Theme.highlightColor
    property color secondaryHighlightColor: Theme.secondaryHighlightColor
    property color highlightBackgroundColor: Theme.highlightBackgroundFromColor(highlightColor, colorScheme)
    property int colorScheme: Theme.colorScheme
    property int _listWidth: isPortrait ? Screen.width : Screen.height - (Screen.width / 2)
    property bool _minimized: !Qt.application.active
    property alias contentId: ambience.contentId
    property alias source: ambience.url
    property alias ambience: ambience
    property Component topHeader
    property bool showWallpaper: true
    property color _originalHighlightColor
    property color _originalSecondaryHighlightColor
    property bool _colorChanged
    property bool _completed
    property bool _hasDataCapability: capabilityDataContextProperty.value || capabilityDataContextProperty.value === undefined
    property bool _hasVoiceCapability: capabilityVoiceContextProperty.value || capabilityVoiceContextProperty.value === undefined
    property bool fadeAmbiencePicture
    readonly property real backgroundHeight: colorSchemeCombo.visible ? colorSchemeCombo.y : highlightSlider.y
    property alias enableColorSchemeSelection: colorSchemeCombo.visible

    property Page page: {
        var parentItem = parent
        while (parentItem) {
            if (parentItem.hasOwnProperty('__silica_page')) {
                return parentItem
            }
            parentItem = parentItem.parent
        }
        return null
    }

    contentHeight: settingsList.height

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

            highlightSlider.updateHue()
            colorSchemeCombo.currentIndex = ambience.colorScheme

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
                            && availableActionsModel.get(k).property === property) {
                        availableActionsModel.remove(k)
                    }
                } else {
                    if (j < actionsModel.count && actionsModel.get(j).property === property) {
                        actionsModel.remove(j)
                    }
                    if (k == availableActionsModel.count
                            || availableActionsModel.get(k).property !== property) {
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

            if (ambience.applicationWallpaperUrl == "") { // Type coercion is required here. Don't correct this to ===.
                Ambience.create(ambience.url)
            }
        }
    }

    anchors.fill: parent
    Column {
        id: settingsList
        width: root.width

        Loader {
            width: parent.width
            sourceComponent: root.topHeader
        }

        Item {
            width: parent.width
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
                enabled: root.fadeAmbiencePicture
            }
        }

        MouseArea {
            id: highlightColorReset

            width: root.width
            height: root.showWallpaper ? Theme.itemSizeLarge : Theme.itemSizeMedium

            clip: true
            enabled: root._colorChanged
            onClicked: {
                ambience.highlightColor = root._originalHighlightColor
                ambience.secondaryHighlightColor = root._originalSecondaryHighlightColor
                highlightSlider.hue = Color.hue(ambience.highlightColor)
                root._colorChanged = false
            }
            Loader {
                active: root.showWallpaper
                anchors.fill: parent
                sourceComponent: SilicaPrivate.Wallpaper {
                    anchors.fill: parent
                    source: ambience.applicationWallpaperUrl
                    colorScheme: ambience.colorScheme

                    windowRotation: -page.rotation
                }
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

            Column {
                anchors {
                    left: dot.right
                    leftMargin: Theme.paddingMedium + Theme.paddingSmall
                    verticalCenter: dot.verticalCenter
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }

                Label {
                    id: colorLabel

                    //: Text to indicate color changes
                    //% "Ambience color"
                    text: qsTrId("jolla-gallery-ambience-la-ambience-color")
                    color: Theme.rgba(
                               highlightColorReset.pressed
                               ? root._originalHighlightColor
                               : ambience.highlightColor,
                                 0.7)
                    width: parent.width
                    wrapMode: Text.Wrap
                }

                Label {
                    id: resetLabel
                    //: Text to indicate color changes
                    //% "Tap to reset"
                    text: qsTrId("jolla-gallery-ambience-la-reset-color")
                    color: Theme.rgba(
                               highlightColorReset.pressed
                               ? root._originalHighlightColor
                               : ambience.primaryColor,
                                 0.7)
                    font.pixelSize: Theme.fontSizeSmall
                    opacity: highlightColorReset.enabled ? 1.0 : 0.0
                    height: opacity * implicitHeight
                    Behavior on opacity { FadeAnimation { target: resetLabel; duration: 100 }}
                    width: parent.width
                    wrapMode: Text.Wrap
                }
            }
        }

        ComboBox {
            id: colorSchemeCombo
            //: Style of ambience, either Light or Dark.
            //% "Style"
            label: qsTrId("jolla-gallery-ambience-la-style")
            currentIndex: ambience.colorScheme
            labelColor: down ? root.highlightColor : root.primaryColor
            valueColor: root.highlightColor
            highlightedColor: Theme.rgba(root.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
            visible: false
            menu: ContextMenu {
                backgroundColor: root.highlightBackgroundColor
                highlightColor: Theme.rgba(root.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                MenuItem {
                    //: Dark ambience color scheme
                    //% "Dark"
                    text: qsTrId("jolla-gallery-ambience-la-dark")
                    color: down || highlighted ? root.primaryColor : root.highlightColor
                    onClicked: {
                        ambience.colorScheme = Theme.LightOnDark
                        ambience.primaryColor = Theme.lightPrimaryColor
                        ambience.secondaryColor = Theme.lightSecondaryColor
                        ambience.highlightColor = Theme.highlightFromColor(ambience.highlightColor, Theme.LightOnDark)
                        ambience.secondaryHighlightColor = Theme.secondaryHighlightFromColor(ambience.highlightColor, Theme.LightOnDark)
                    }
                }
                MenuItem {
                    //: Light ambience color scheme
                    //% "Light"
                    text: qsTrId("jolla-gallery-ambience-la-light")
                    color: down || highlighted ? root.primaryColor : root.highlightColor
                    onClicked: {
                        ambience.colorScheme = Theme.DarkOnLight
                        ambience.primaryColor = Theme.darkPrimaryColor
                        ambience.secondaryColor = Theme.darkSecondaryColor
                        ambience.highlightColor = Theme.highlightFromColor(ambience.highlightColor, Theme.DarkOnLight)
                        ambience.secondaryHighlightColor = Theme.secondaryHighlightFromColor(ambience.highlightColor, Theme.DarkOnLight)
                    }
                }
            }
        }

        ColorSlider {
            id: highlightSlider
            minimumValue: 0
            maximumValue: 1
            stepSize: 0.01
            anchors.horizontalCenter: parent.horizontalCenter
            secondaryColor: root.secondaryColor
            highlightColor: root.highlightColor
            width: parent.width - Theme.paddingLarge

            //: Highlight color for ambience
            //% "Ambience color"
            label: qsTrId("jolla-gallery-ambience-la-ambience-color")

            Component.onCompleted: updateHue()

            function updateHue() {
                highlightSlider.enabled = false
                highlightSlider.hue = Color.hue(ambience.highlightColor)
                highlightSlider.enabled = true
            }

            onHueChanged: {
                if (enabled) {
                    root._colorChanged = true
                    ambience.highlightColor = Theme.highlightFromColor(Color.fromHsva(hue, 1.0, 0.5, 1.0), ambience.colorScheme)
                    ambience.secondaryHighlightColor = Theme.secondaryHighlightFromColor(ambience.highlightColor, ambience.colorScheme)
                }
            }
        }

        TextField {
            id: ambienceName

            width: root._listWidth
            horizontalAlignment: TextInput.AlignLeft
            textLeftMargin: Theme.horizontalPageMargin
            color: highlighted ? highlightColor : root.primaryColor
            placeholderColor: highlighted ? secondaryHighlightColor : root.secondaryColor

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
                page.focus = true
            }
        }

        MouseArea {
            id: favoriteButton

            property bool down: pressed && containsMouse

            width: root.width
            height: Theme.itemSizeLarge
            onClicked: {
                ambience.favorite = !ambience.favorite
            }

            Image {
                id: favoriteIcon

                x: Theme.horizontalPageMargin
                source: (ambience.favorite ? "image://theme/icon-m-favorite-selected?" : "image://theme/icon-m-favorite?")
                        + (favoriteButton.down ? root.highlightColor : root.primaryColor)
                anchors.verticalCenter: favoriteButton.verticalCenter
            }

            Label {
                anchors {
                    left: favoriteIcon.right
                    right: favoriteButton.right
                    verticalCenter: favoriteButton.verticalCenter
                    margins: Theme.paddingMedium
                }

                //% "Select as favorite"
                text: qsTrId("jolla-gallery-ambience-la-select-as-favorite")
                color: favoriteButton.down ? root.highlightColor : root.primaryColor
            }
        }

        SectionHeader {
            //% "Actions"
            text: qsTrId("jolla-gallery-ambience-la-actions")
            color: root.highlightColor
        }
        Label {
            anchors {
                left: settingsList.left
                right: settingsList.right
                margins: Theme.horizontalPageMargin
            }

            font.pixelSize: Theme.fontSizeExtraSmall
            wrapMode: Text.Wrap
            color: root.highlightColor

            //% "You can define a set of actions to trigger when this ambience is selected"
            text: qsTrId("jolla-gallery-ambience-la-actions-explanation")
        }

        Item {
            // This is a minor variation on ColumnView, which is using the ListView's contentHeight
            // to determine the occupied height instead of a nomaical delegate size * the number of
            // items. This means it is able to cope with unexpected heights which ListView knows about
            // like remove animations.
            id: actionsContainer
            width: root.width
            height: actionsView.contentHeight

            ListView {
                id: actionsView

                width: root.width
                height: root.height
                y: contentY
                contentY: root.contentY - originY - actionsContainer.y
                interactive: false

                model: ambience.actions
                delegate: Item {
                    id: actionButton

                    function expand() {
                        if (loader.item && loader.item.expand !== undefined) {
                            loader.item.expand()
                        }
                    }

                    width: root.width
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

                        width: root.width
                        sourceComponent: model.property != "" ? ambienceActions[model.property].editor  : null
                        onItemChanged: {
                            if (item) {
                                item.primaryColor = Qt.binding(function() { return root.primaryColor })
                                item.secondaryColor = Qt.binding(function() { return root.secondaryColor })
                                item.highlightColor = Qt.binding(function() { return root.highlightColor })
                                item.colorScheme = Qt.binding(function() { return root.colorScheme })
                                if (item.secondaryHighlightColor !== undefined) {
                                    item.secondaryHighlightColor = Qt.binding(function() { return root.secondaryHighlightColor })
                                }
                            }
                        }
                    }

                    IconButton {
                        anchors {
                            right: actionButton.right
                            rightMargin: Theme.horizontalPageMargin
                            verticalCenter: actionButton.top
                            verticalCenterOffset: Theme.itemSizeSmall / 2
                        }

                        icon {
                            source: "image://theme/icon-m-clear"
                            highlighted: _showPress
                            highlightColor: root.highlightColor
                            color: root.primaryColor
                        }

                        onClicked: {
                            ambienceActions[model.property].clearValue(ambience)
                            ambience.changed()
                        }
                    }
                }
            }
        }

        Item {
            width: 1
            height: Theme.paddingLarge
        }

        ListButton {
            //% "Add actions"
            text: qsTrId("jolla-gallery-ambience-la-add-actions")
            icon.source: "image://theme/icon-m-add"
            enabled: availableActionsModel.count > 0

            primaryColor: root.primaryColor
            highlightColor: root.highlightColor
            highlightedColor: Theme.rgba(ambience.highlightColor, Theme.highlightBackgroundOpacity)

            onClicked: pageStack.animatorPush(addActionsPage)
        }
    }

    VerticalScrollDecorator {}

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
                            pageStack.animatorPush(action.dialog, {
                                                       "ambience": ambience,
                                                       "acceptDestination": page,
                                                       "acceptDestinationAction": PageStackAction.Pop
                                                   })
                        } else {
                            ListView.delayRemove = true
                            if (!action.hasValue(ambience)) {
                                action.setDefaultValue(ambience)
                                ambience.changed()
                            }
                            pageStack.pop()
                            for (var i = 0; i < actionsModel.count; ++i) {
                                if (actionsModel.get(i).property == action.property) {
                                    root.positionViewAtIndex(i, ListView.Contain)
                                    break
                                }
                            }
                            for (i = 0; i < root.contentItem.children.length; ++i) {
                                var item = root.contentItem.children[i]
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
