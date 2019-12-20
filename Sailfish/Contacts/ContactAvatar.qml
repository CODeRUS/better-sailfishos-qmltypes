import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0 as Contacts

MouseArea {
    id: root

    property var contact
    property string imageSource
    property Item menuParent: root
    property bool readOnly: !contact || !ContactsUtil.isWritableContact(contact)
    property real contentHeight: (!readOnly || avatarAvailable) ? Math.round(Screen.width / 3) : avatarImage.implicitHeight

    readonly property bool avatarAvailable: avatarImage.available
    property ListModel _avatarUrlModel: ListModel {}
    property var _avatarUrls: []
    property string _avatarUrl
    property Item _contextMenu

    signal contactModified()

    function _setAvatarPath(path) {
        contact.avatarPath = path
        contactModified()

        _updateAvatarMenu()
    }

    function _changeAvatar() {
        if (_avatarUrl === '' &&
            (!_avatarUrls.length || (_avatarUrls.length == 1 && _avatarUrls[0] == ''))) {
            // No avatar - when we support camera, show the context menu
            // For now, just open the gallery immediately
            _avatarFromGallery()
            return
        }

        if (!_contextMenu) {
            var component = Qt.createComponent("ContactAvatarContextMenu.qml")
            _contextMenu = component.createObject(root.menuParent, {
                "avatarUrl": root._avatarUrl,
                "avatarUrlModel": root._avatarUrlModel
            })
            _contextMenu.updateAvatarMenu.connect(_updateAvatarMenu)
            _contextMenu.avatarFromGallery.connect(_avatarFromGallery)
            _contextMenu.setAvatarPath.connect(_setAvatarPath)
        }
        _contextMenu.open(root.menuParent)
    }

    function _avatarFromGallery() {
        // TODO fix bug: if the contact card is popped immediately after the image is selected, the contact
        // is not saved with the new image.
        var component = Qt.createComponent("AvatarPickerPage.qml")
        var picker = component.createObject(pageStack)
        picker.avatarUrlChanged.connect(function(avatarUrl) {
            root._setAvatarPath(avatarUrl)
            picker.destroy()
        })
        pageStack.animatorPush(picker)
    }

    function _updateAvatarModel() {
        // Get URLs for all avatars that are not covers
        _avatarUrls = contact.avatarUrlsExcluding('cover')
        _avatarUrl = contact.filteredAvatarUrl(['local', 'picture', ''])
        _updateAvatarMenu()
    }

    function _removeFileScheme(url) {
        var fileScheme = 'file:///'
        if (url && url.length >= fileScheme.length && url.substring(0, fileScheme.length) == fileScheme) {
            url = url.substring(fileScheme.length - 1)
        }
        return url
    }

    function _updateAvatarMenu() {
        if (_contextMenu && _contextMenu.height > 0) {
            // Don't update while the context menu is open
            _contextMenu.updateOnClose = true
            return
        }

        var currentUrl = _removeFileScheme(_avatarUrl)

        _avatarUrlModel.clear()
        for (var i = 0; i < _avatarUrls.length; ++i) {
            var url = _removeFileScheme(_avatarUrls[i])
            if (url && url != currentUrl) {
                var existing = false
                for (var j = 0; j < _avatarUrlModel.count; ++j) {
                    if (_avatarUrlModel.get(j).url == url) {
                        existing = true
                        break
                    }
                }
                if (!existing) {
                    _avatarUrlModel.append({ 'url': url })
                }
            }
        }
    }

    width: contentHeight
    height: contentHeight + (_contextMenu ? _contextMenu.height : 0)

    enabled: !readOnly

    onClicked: {
        _changeAvatar()
    }

    onContactChanged: {
        if (contact) {
            _updateAvatarModel()
        }
    }

    on_AvatarUrlChanged: {
        changeAnimation.start()
    }

    SequentialAnimation {
        id: changeAnimation

        FadeAnimator {
            target: avatarImage
            to: 0
        }
        ScriptAction {
            script: root.imageSource = root._avatarUrl
        }
        FadeAnimator {
            target: avatarImage
            to: 1
        }
    }

    Connections {
        target: contact
        onAvatarUrlChanged: {
            _updateAvatarModel()
        }
    }

    AvatarImage {
        id: avatarImage

        itemSize: contentHeight
        source: root.imageSource
    }

    Rectangle {
        id: placeholderBackground

        width: root.contentHeight
        height: root.contentHeight
        color: "white"

        enabled: !root.readOnly && root.imageSource === "" && contact != null
        opacity: enabled ? 0.1 : 0
        Behavior on opacity { FadeAnimator { duration: 500 } }  // Fade in slowly for less abrupt effect
    }

    // Highlight shown on top of avatar
    Rectangle {
        width: avatar.contentHeight
        height: avatar.contentHeight
        color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
        visible: avatar.containsPress
    }

    HighlightImage {
        anchors.centerIn: parent
        source: "image://theme/icon-m-camera"
        highlighted: root.containsPress

        enabled: placeholderBackground.enabled
        opacity: enabled ? 1 : 0
        Behavior on opacity { FadeAnimator { } }
    }
}
