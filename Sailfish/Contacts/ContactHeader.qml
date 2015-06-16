import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0

Item {
    id: root

    property Person contact
    property bool readOnly

    signal contactModified
    signal avatarFromGallery
    signal avatarFromCamera

    property var _avatarUrls: []
    property string _avatarUrl
    property string _coverPath

    property Item _contextMenu
    property real _headerHeight: Theme.itemSizeLarge * 3 + Theme.paddingMedium

    height: _headerHeight + (_contextMenu ? _contextMenu.height : 0)
    width: parent ? parent.width : 0

    function showContextMenu() {
        if (!_contextMenu) {
            _contextMenu = contextMenuComponent.createObject(root)
        }
        _contextMenu.show(root)
    }

    function setAvatarPath(path) {
        contact.avatarPath = path
        contactModified()

        updateAvatarMenu()
    }

    function changeAvatar() {
        if (_avatarUrl === '' &&
            (!_avatarUrls.length || (_avatarUrls.length == 1 && _avatarUrls[0] == ''))) {
            // No avatar - when we support camera, show the context menu
            // For now, just open the gallery immediately
            avatarFromGallery()
            return
        }

        showContextMenu()
    }

    function removeAvatar() {
        // Set an empty path to override tother images
        setAvatarPath('')
    }

    function updateAvatarModel() {
        // Get URLs for all avatars that are not covers
        _avatarUrls = contact.avatarUrlsExcluding('cover')

        _avatarUrl = contact.filteredAvatarUrl(['local', 'picture', ''])
        _coverPath = contact.filteredAvatarUrl(['cover'])

        updateAvatarMenu()
    }

    function removeFileScheme(url) {
        var fileScheme = 'file:///'
        if (url && url.length >= fileScheme.length && url.substring(0, fileScheme.length) == fileScheme) {
            url = url.substring(fileScheme.length - 1)
        }
        return url
    }

    function updateAvatarMenu() {
        if (_contextMenu && _contextMenu.height > 0) {
            // Don't update while the context menu is open
            _contextMenu.updateOnClose = true
            return
        }

        var currentUrl = removeFileScheme(_avatarUrl)

        _avatarUrlModel.clear()
        for (var i = 0; i < _avatarUrls.length; ++i) {
            var url = removeFileScheme(_avatarUrls[i])
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

    property ListModel _avatarUrlModel: ListModel {}

    function groupByPresence(states) {
        var groups = {}
        var addedIndices = []

        // Only show the first 7 accounts; more will not fit on screen
        var maxAccounts = 7

        // Add the indices of the accounts in descending presence state order
        var orderedStates = [ Person.PresenceAvailable, Person.PresenceAway, Person.PresenceExtendedAway, Person.PresenceBusy ]
        var stateNames = [ 'available', 'away', 'away', 'busy' ]
        for (var i = 0; i < orderedStates.length; ++i) {
            var state = orderedStates[i]
            var name = stateNames[i]

            var stateIndices = []
            for (var j = 0; j < states.length; ++j) {
                if (states[j] == state) {
                    if (addedIndices.length < maxAccounts) {
                        stateIndices.push(j)
                        addedIndices.push(j)
                    }
                }
            }
            if (stateIndices.length) {
                if (name in groups) {
                    groups[name] = groups[name].contact(stateIndices)
                } else {
                    groups[name] = stateIndices
                }
            }
        }

        if ((addedIndices.length < states.length) && (addedIndices.length < maxAccounts)) {
            // Add any account indices we haven't already added
            var otherIndices = []
            for (var i = 0; i < states.length; ++i) {
                for (var j = 0; j < addedIndices.length; ++j) {
                    if (addedIndices[j] == i) {
                        break
                    }
                }
                if (j == addedIndices.length) {
                    if (addedIndices.length < maxAccounts) {
                        otherIndices.push(i)
                        addedIndices.push(i)
                    }
                }
            }
            groups['unknown'] = otherIndices
        }

        return groups
    }

    function updateModelFromGroup(model, group) {
        var presentUris = []
        var removeIndices = []

        // Remove any items in the model but not in the group
        for (var i = 0; i < model.count; ++i) {
            var modelGroup = model.get(i)
            for (var j = 0; j < group.length; ++j) {
                if (group[j].uri == modelGroup.uri) {
                    presentUris.push(modelGroup.uri)
                    break
                }
            }
            if (j == group.length) {
                removeIndices.push(i)
            }
        }

        while (removeIndices.length) {
            var index = removeIndices.pop()
            model.remove(index)
        }

        // Add any groups not yet in the model
        for (var i = 0; i < group.length; ++i) {
            for (var j = 0; j < presentUris.length; ++j) {
                if (presentUris[j] == group[i].uri) {
                    break
                }
            }
            if (j == presentUris.length) {
                model.append({ 'uri': group[i].uri, 'iconPath': group[i].iconPath })
            }
        }
    }

    function getPresenceData() {
        var data = {}

        var accountDetails = contact.accountDetails

        var states = []
        for (var i = 0; i < accountDetails.length; ++i) {
            states.push(accountDetails[i].presenceState)
        }
        var groups = groupByPresence(states)

        for (var group in groups) {
            var indices = groups[group]

            var accounts = []
            for (var i = 0; i < indices.length; ++i) {
                var account = accountDetails[indices[i]]
                accounts.push({
                    'uri': account.accountPath + ':' + account.accountUri,
                    'state': account.presenceState,
                    'iconPath': account.iconPath
                })
            }
            data[group] = accounts
        }

        return data
    }

    function presenceGroup(presenceGroups, state) {
        if (state in presenceGroups) {
            return presenceGroups[state]
        }
        return []
    }

    function updatePresenceModel() {
        var presenceData = getPresenceData()

        updateModelFromGroup(availableModel, presenceGroup(presenceData, 'available'))
        updateModelFromGroup(awayModel, presenceGroup(presenceData, 'away'))
        updateModelFromGroup(busyModel, presenceGroup(presenceData, 'busy'))
        updateModelFromGroup(unknownModel, presenceGroup(presenceData, 'unknown'))
    }

    function updateContactData() {
        updateAvatarModel()
        updatePresenceModel()
    }

    ListModel { id: availableModel }
    ListModel { id: awayModel }
    ListModel { id: busyModel }
    ListModel { id: unknownModel }

    ListModel {
        id: presenceModel

        Component.onCompleted: {
            presenceModel.append({ 'presenceState': Person.PresenceAvailable, 'groupModel': availableModel })
            presenceModel.append({ 'presenceState': Person.PresenceAway, 'groupModel': awayModel })
            presenceModel.append({ 'presenceState': Person.PresenceBusy, 'groupModel': busyModel })
            presenceModel.append({ 'presenceState': Person.PresenceUnknown, 'groupModel': unknownModel })
        }
    }

    onContactChanged: {
        if (contact) {
            updateContactData()
        }
    }

    Connections {
        target: contact
        onContactChanged: updateContactData()
        onCompleteChanged: updateContactData()
        onAvatarUrlChanged: updateAvatarModel()
        onAccountDetailsChanged: updatePresenceModel()
    }

    Rectangle {
        width: parent.width
        height: _headerHeight
        color: Theme.highlightBackgroundColor
        opacity: 0.1
        visible: !coverImage.visible
    }
    Image {
        id: coverImage
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: _headerHeight
        fillMode: Image.PreserveAspectCrop
        source: _coverPath // TODO: implement cover caching on local device!
        visible: _coverPath != ''
        opacity: status == Image.Ready ? 0.4 : 0.0
        onStatusChanged: if (status == Image.Loading) fadeAnim.enabled = true
        Behavior on opacity { id: fadeAnim; enabled: false; FadeAnimation {} }
    }

    BackgroundItem {
        id: avatar

        property string imageSource

        property string avatarUrl: root._avatarUrl
        onAvatarUrlChanged: changeAnimation.start()

        Component.onCompleted: {
            imageSource = avatarUrl
        }

        SequentialAnimation {
            id: changeAnimation
            FadeAnimation {
                target: image
                to: 0
            }
            ScriptAction {
                script: avatar.imageSource = avatar.avatarUrl
            }
            FadeAnimation {
                target: image
                to: 1
            }
        }

        // Anchor to the top, because the bottom moves when the context menu opens
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            top: parent.top
            topMargin: _headerHeight - height - Theme.paddingLarge
        }
        height: screen.width / 3
        width: height
        visible: contact ? true : false
        enabled: !readOnly

        Image {
            id: image
            anchors.fill: parent
            sourceSize.height: parent.height
            fillMode: Image.PreserveAspectCrop
            source: avatar.imageSource ? avatar.imageSource : ''
            visible: avatar.imageSource !== ''
            cache: false
            clip: visible
        }
        Rectangle {
            anchors.fill: parent
            color: 'white'
            opacity: 0.1
            visible: avatar.imageSource === ''
        }
        Image {
            anchors.centerIn: parent
            // TODO: Show dummy avatar on readOnly case?
            source: "image://theme/icon-m-add"
            visible: avatar.imageSource === '' && !readOnly
        }

        onClicked: changeAvatar()
        onPressAndHold: changeAvatar()
    }

    Row {
        id: presenceIndicators

        anchors {
            bottom: avatar.bottom
            left: avatar.right
            leftMargin: Theme.paddingMedium
        }

        Repeater {
            model: presenceModel

            Column {
                spacing: Theme.paddingMedium

                property QtObject groupModel: model.groupModel

                // We can't use a Row here, because row add/remove transition can only affect x and y properties
                ListView {
                    id: accounts

                    orientation: ListView.Horizontal
                    interactive: false

                    height: Theme.paddingLarge

                    property Item removingItem
                    property Item addingItem

                    // The group must be at least 1 pixel wide, or it won't expand when an item is added
                    width: Math.max(1, groupModel.count * delegateWidth + (removingItem ? removingItem.width : 0) - (addingItem ? delegateWidth - addingItem.width : 0))

                    // We can't use spacing, because the groups cannot become invisible and still react
                    // correctly to additions...
                    property int delegateWidth: Theme.paddingLarge + Theme.paddingMedium
                    cacheBuffer: delegateWidth

                    model: groupModel

                    delegate: Item {
                        id: delegateItem
                        width: accounts.delegateWidth
                        height: Theme.paddingLarge
                        ListView.delayRemove: true

                        Image {
                            width: Theme.paddingLarge
                            height: width
                            source: model.iconPath

                            Rectangle {
                                anchors.fill: parent
                                color: 'lightblue'
                                visible: parent.source == ''
                            }
                        }

                        ListView.onAdd: SequentialAnimation {
                            ScriptAction { script: accounts.addingItem = delegateItem; }
                            PropertyAction { target: delegateItem; property: 'width'; value: 0 }
                            PropertyAction { target: delegateItem; property: 'opacity'; value: 0 }
                            PauseAnimation { duration: 150 }
                            NumberAnimation { target: delegateItem; property: 'width'; to: accounts.delegateWidth; duration: 150; easing.type: Easing.InOutQuad }
                            NumberAnimation { target: delegateItem; property: 'opacity'; to: 1; duration: 150; easing.type: Easing.InOutQuad }
                            ScriptAction { script: accounts.addingItem = null; }
                        }

                        ListView.onRemove: SequentialAnimation {
                            ScriptAction { script: accounts.removingItem = delegateItem; }
                            NumberAnimation { target: delegateItem; property: 'opacity'; to: 0; duration: 150; easing.type: Easing.InOutQuad }
                            NumberAnimation { target: delegateItem; property: 'width'; to: 0; duration: 150; easing.type: Easing.InOutQuad }
                            PropertyAction { target: delegateItem; property: 'ListView.delayRemove'; value: false }
                            ScriptAction { script: accounts.removingItem = null; }
                        }
                    }
                }

                ContactPresenceIndicator {
                    width: (accounts.width > 1) ? accounts.width - Theme.paddingMedium : 0
                    presenceState: model.presenceState
                }
            }
        }
    }

    IconButton {
        id: icon
        width: Theme.itemSizeSmall
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin - Theme.paddingLarge
            top: parent.top
            topMargin: _headerHeight - height
        }
        icon.source: contact && contact.favorite ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
        visible: contact ? true : false
        // Note - enabled even in readOnly case:
        enabled: contact && contact.id != 0 && contact.complete
        onClicked: {
            contact.favorite = !contact.favorite
            contactModified()
        }
    }

    function getNameText() {
        if (contact) {
            if (contact.firstName || contact.lastName) {
                if (contact.firstName && contact.lastName) {
                    return contact.firstName + '\n' + contact.lastName
                }
                return contact.firstName ? contact.firstName : contact.lastName
            }
            return contact.displayLabel
        }
        return ''
    }

    function getDetailText() {
        if (contact && contact.complete) {
            var items = []
            // TODO: find the 'preferred' nickname
            var nicknames = contact.nicknameDetails
            for (var i = 0; i < nicknames.length; ++i) {
                // If the contact nickname is already the display label, don't show it here
                if (nicknames[i].nickname != getNameText()) {
                    items.push(nicknames[i].nickname)
                    // Only use one nickname
                    break
                }
            }
            if (contact.companyName) {
                items.push(contact.companyName)
            }
            if (contact.department) {
                items.push(contact.department)
            }
            if (contact.title || contact.role) {
                if (contact.title) {
                    items.push(contact.title)
                } else {
                    items.push(contact.role)
                }
            }
            return items.join(', ')
        }
        return ''
    }

    Label {
        id: nameLabel
        y: Theme.paddingLarge
        width: parent.width - Theme.horizontalPageMargin
        font {
            family: Theme.fontFamilyHeading
            pixelSize: Theme.fontSizeLarge
        }
        color: Theme.highlightColor
        horizontalAlignment: Text.AlignRight
        wrapMode: Text.WordWrap
        maximumLineCount: 4
        text: getNameText()
    }

    Label {
        y: nameLabel.y + nameLabel.height + Theme.paddingMedium
        anchors {
            top: nameLabel.bottom
            topMargin: Theme.paddingSmall
            right: nameLabel.right
            left: presenceIndicators.left
        }
        font {
            family: Theme.fontFamilyHeading
            pixelSize: Theme.fontSizeExtraSmall
        }
        color: Theme.highlightColor
        opacity: 0.6
        horizontalAlignment: Text.AlignRight
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        text: getDetailText()
    }

    Component {
        id: contextMenuComponent

        ContextMenu {
            id: menu

            property bool updateOnClose: false
            onHeightChanged: {
                if (height == 0 && updateOnClose) {
                    root.updateAvatarMenu()
                    updateOnClose = false
                }
            }

            MenuItem {
                //: Select avatar from gallery
                //% "Select from gallery"
                text: qsTrId("components_contacts-me-avatar_gallery")
                onClicked: avatarFromGallery()
            }
            /* Not currently supported
            MenuItem {
                //: Create avatar with camera
                //% "Create with camera"
                text: qsTrId("components_contacts-me-avatar_camera")
                onClicked: avatarFromCamera()
            }
            */
            Repeater {
                model: root._avatarUrlModel

                Item {
                    property bool down
                    property bool highlighted
                    property int __silica_menuitem

                    signal clicked

                    width: parent ? parent.width : Screen.width
                    height: avatarImage.height + 2*Theme.paddingSmall

                    Image {
                        id: avatarImage
                        width: Theme.itemSizeLarge
                        height: width
                        x: (parent.width - width) / 2
                        y: Theme.paddingSmall
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        source: model.url
                    }

                    onClicked: setAvatarPath(modelData)
                }
            }
            MenuItem {
                //: Remove avatar
                //% "No image"
                text: qsTrId("components_contacts-me-avatar_remove")
                visible: root._avatarUrl != ''
                onClicked: removeAvatar()
            }
        }
    }
}

