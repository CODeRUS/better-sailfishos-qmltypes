import QtQuick 2.4
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import com.jolla.gallery.facebook 1.0
import org.nemomobile.social 1.0
import org.nemomobile.socialcache 1.0
import Sailfish.Gallery 1.0

FullscreenContentPage {
    id: fullscreenPage

    property AccessTokensProvider accessTokensProvider
    property FacebookImageCacheModel model
    property int currentIndex: -1

    // Private properties
    property string _currentPhotoId
    property string _prevPhotoId
    property string _currentPhotoUserId
    property real _rightMargin: pageStack.currentPage.isLandscape ? Theme.paddingLarge : Theme.horizontalPageMargin

    allowedOrientations: window.allowedOrientations

    // The following handlers make the Facebook elements to fetch new data about likes and comments.
    // The data is being fetched only when overlay is visible with the likes and comments items.
    // This way we decrease network load and don't request any data which user is not interested in.
    property alias overlayActive: overlay.active
    onOverlayActiveChanged: if (overlay.active) fetchData()

    Component.onCompleted: {
        updateAccessToken()
        slideshowView.positionViewAtIndex(currentIndex, PathView.Center)
    }

    onCurrentIndexChanged: {
        updateAccessToken()
        if (!overlay.active) {
            // Start timer to test if user hasn't flicked for a while, start downloading
            // data from the network
            imageFlickTimer.photoId = _currentPhotoId
            imageFlickTimer.restart()
        }
    }

    function updateAccessToken() {
        facebook.accessToken = ""
        if (model) {
            accessTokensProvider.requestAccessToken(model.getField(currentIndex, FacebookImageCacheModel.AccountId))
        }
    }

    function fetchData() {
        photoAndLikesModel.repopulate()
    }

    function formattedTimestamp(isostr) {
        var parts = isostr.match(/\d+/g)
        var fixedDate = new Date(Date.UTC(parts[0], parts[1] - 1, parts[2], parts[3], parts[4], parts[5]))
        return Format.formatDate(fixedDate, Formatter.TimepointRelative)
    }

    // Returns string formatted e.g. "You, Mike M and 3 others like this
    function likeInformation() {
        // Not very pretty code but localization and how this message
        // is expressed requires quite many variations
        var isLikedByPhotoUser = photoAndLikesModel.node.liked
        var photoUserName = ""
        var users = new Array
        for (var i = 0; i < photoAndLikesModel.count; i++) {
            if (photoAndLikesModel.relatedItem(i).userIdentifier !== _currentPhotoUserId) {
                users.push(photoAndLikesModel.relatedItem(i).userName)
            }
        }

        if (photoAndLikesModel.count == 1) {
            if (isLikedByPhotoUser) {
                //% "You like this"
                return qsTrId("jolla_gallery_facebook-la-you-like-this")
            } else {
                //% "%1 likes this"
                return qsTrId("gallery-fb-la-one-friend-likes-this")
                     .arg(users[0])
            }
        }
        if (photoAndLikesModel.count == 2) {
            if (isLikedByPhotoUser) {
                //% "You and %1 like this"
                return qsTrId("jolla_gallery_facebook-la-you-and-another-friend-likes-this")
                    .arg(users[0])
            } else {
                //% "%1 and %2 like this"
                return qsTrId("jolla_gallery_facebook-la-two-friend-likes-this")
                    .arg(users[0])
                    .arg(users[1])
            }
        }
        if (photoAndLikesModel.count > 2) {
            if (isLikedByPhotoUser) {
                //% "You, %1 and %n others like this"
                return qsTrId("jolla_gallery_facebook-la-you-and-multiple-friend-like-this", photoAndLikesModel.likesCount - 2)
                    .arg(users[0])
            } else {
                //% "%1 and %2 and %n others like this"
                return qsTrId("jolla_gallery_facebook-la-multiple-friend-like-this", photoAndLikesModel.likesCount - 2)
                    .arg(users[0])
                    .arg(users[1])
            }
        }
        // Return an empty string for 0 likes
        return ""
    }

    Connections {
        target: accessTokensProvider
        onAccessTokenRetrieved: {
            var currentAccountId = fullscreenPage.model.getField(currentIndex, FacebookImageCacheModel.AccountId)
            if (currentAccountId == accountId) {
                facebook.accessToken = accessToken
                if (overlay.active) {
                    fullscreenPage.fetchData()
                }
            }
        }
    }

    Facebook { id: facebook }

    // The likes model controls basically everything
    // It's central node is used to perform like / unlike operations
    // and also provide the number of likes and comments.
    // This model is used to print a nice message about likes.
    // Additionnal properties added helps to track if there is
    // a loading in progress, and have persistant displays of
    // the number of likes / comments during loading operations.
    SocialNetworkModel {
        id: photoAndLikesModel
        property bool loading
        property bool liked: true
        property int likesCount: -1
        property int commentsCount: -1
        property string likeInfo

        function refreshLikesInfo() {
            photoAndLikesModel.loading = false
            photoAndLikesModel.liked = node.liked
            photoAndLikesModel.likesCount = node.likesCount
            photoAndLikesModel.commentsCount = node.commentsCount
            photoAndLikesModel.likeInfo = fullscreenPage.likeInformation()
        }

        socialNetwork: facebook
        nodeIdentifier: fullscreenPage._currentPhotoId
        // If you have a lot of likes, Facebook will provide
        // them as paginated. So it is not reliable to get
        // the likes by counting the number of elements in
        // this model.
        //
        // We still need (up to) the first 3 people who liked
        // that photo to display the "a, b and c liked that"
        // string. So we only need to retrieve 3 likes.
        filters: ContentItemTypeFilter { type: Facebook.Like; limit: 3 }
        onNodeIdentifierChanged: {
            photoAndLikesModel.loading = true
            photoAndLikesModel.liked = false
            photoAndLikesModel.likesCount = -1
            photoAndLikesModel.commentsCount = -1
            photoAndLikesModel.likeInfo = ""
        }

        onStatusChanged: {
            switch (status) {
            case Facebook.Idle:
                refreshLikesInfo()
                break
            }
        }
    }

    // This connection is used to react
    // to changes of status of the node attached
    // to likesModel
    Connections {
        target: photoAndLikesModel.node
        onStatusChanged:  {
            switch (photoAndLikesModel.node.status) {
            case Facebook.Idle:
                photoAndLikesModel.repopulate()
                break
            default:
                photoAndLikesModel.loading = true
                break
            }
        }
    }

    SocialNetworkModel {
        id: commentsModel
        socialNetwork: facebook
        nodeIdentifier: fullscreenPage._currentPhotoId
        filters: ContentItemTypeFilter { type: Facebook.Comment }
    }

    // This timer is here to make data fetching a little more intelligent. Data is usually fetched
    // from FB only when user taps view to show overlay controls and/or is flicking images while the likes
    // and comment items are visible. This is the third case, when user flicks and overlay controls are hidden
    // data is not fetched unless user stops flicking for 2 seconds. This might mean that user is interested
    // in that image and will soon also show the controls that causes data fetch, but in this case the data
    // will already be there.
    Timer {
        id: imageFlickTimer
        property string photoId
        interval: 2000
        onTriggered: {
            if (photoId == _currentPhotoId && !overlay.active) {
                fetchData()
            }
        }
    }

    // Element for handling the actual flicking and image buffering
    SlideshowView {
        id: slideshowView

        model: fullscreenPage.model
        currentIndex: fullscreenPage.currentIndex
        onCurrentIndexChanged: fullscreenPage.currentIndex = currentIndex
        interactive: model.count > 1
        clip: true

        delegate: MouseArea {
            property url source: model.image
            width: slideshowView.width
            height: slideshowView.height

            onClicked: overlay.active = !overlay.active

            // Pass information about the current item to the top level view in a case
            // user wants to check comments or add a new one, like etc..
            property bool isCurrentItem: PathView.isCurrentItem
            onIsCurrentItemChanged: {
                if (isCurrentItem) {
                    fullscreenPage._currentPhotoId = model.facebookId
                    fullscreenPage._currentPhotoUserId = model.userId
                }
            }
            Image {
                asynchronous: true
                source: model.image
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
            }
        }
    }

    GalleryOverlay {
        id: overlay

        isImage: true
        source: slideshowView.currentItem ? slideshowView.currentItem.source : ""
        deletingAllowed: false
        editingAllowed: false
        sharingAllowed: false
        anchors.fill: parent
        z: model.count + 100
        topFade.height: socialHeader.height + Theme.itemSizeMedium
        fadeOpacity: 0.7

        additionalActions: Row {
            spacing: Theme.paddingLarge
            IconButton {
                icon.source: "image://theme/icon-m-outline-like?" + Theme.lightPrimaryColor
                highlighted: down || photoAndLikesModel.liked
                enabled: !photoAndLikesModel.loading

                onClicked: {
                    var node = photoAndLikesModel.node
                    if (node.liked) {
                        node.unlike()
                    } else {
                        node.like()
                    }
                }
            }

            IconButton {
                enabled: !photoAndLikesModel.loading
                icon.source: "image://theme/icon-m-outline-chat?" + Theme.lightPrimaryColor
                onClicked: {
                    // We load the comments when we need them
                    commentsModel.nodeIdentifier = fullscreenPage._currentPhotoId
                    commentsModel.repopulate()
                    pageStack.animatorPush(Qt.resolvedUrl("AddCommentPage.qml"), {
                                               nodeIdentifier: _currentPhotoId,
                                               commentsModel: commentsModel,
                                               photoItem: photoAndLikesModel.node,
                                               photoUserId: _currentPhotoUserId
                                           })
                }
            }
        }

        Private.DismissButton {
            id: dismissButton
        }

        Column {
            id: socialHeader
            anchors {
                top: dismissButton.top
                left: parent.left
                right: dismissButton.left
            }

            Row {
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingLarge
                height: dismissButton.height

                Image {
                    source: "image://theme/icon-s-like" + "?" + Theme.highlightColor
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    color: Theme.highlightColor
                    text: photoAndLikesModel.likesCount == -1 ? "" : photoAndLikesModel.likesCount
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.paddingLarge
                }

                Image {
                    source: "image://theme/icon-s-chat" + "?" + Theme.highlightColor
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    color: Theme.highlightColor
                    opacity: photoAndLikesModel.loading ? 0.5 : 1
                    text: photoAndLikesModel.commentsCount == -1 ? "" : photoAndLikesModel.commentsCount
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.paddingLarge
                }
            }

            FontMetrics {
                id: fontMetrics
                font.pixelSize: Theme.fontSizeExtraSmall
            }

            Item {
                width: 1
                height: Theme.paddingSmall
            }

            Label {
                text: photoAndLikesModel.likeInfo
                wrapMode: Text.Wrap
                verticalAlignment: Text.AlignTop
                x: Theme.horizontalPageMargin
                height: text == "" ? fontMetrics.height : implicitHeight
                width: parent.width - x
                opacity: text == "" ? 0 : 1
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor
                Behavior on height { FadeAnimation { property: "height" } }
                Behavior on opacity { FadeAnimation {} }
            }

            Item {
                width: 1
                height: Theme.paddingMedium + Theme.paddingSmall
            }

            Label {
                //% "No title"
                property string unknownNameStr: qsTrId("jolla_gallery_facebook-la-unnamed_photo")
                property string photoNameStr: fullscreenPage.model.getField(fullscreenPage.currentIndex,
                                                                            FacebookImageCacheModel.Title)
                text: photoNameStr == "" ? unknownNameStr : photoNameStr
                height: text == "" ? fontMetrics.height : implicitHeight
                width: parent.width - x
                wrapMode: Text.Wrap
                x: Theme.horizontalPageMargin
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
            }

            Item {
                width: 1
                height: Theme.paddingLarge
            }

            Row {
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingMedium

                Image {
                    source: "image://theme/icon-s-service-facebook"
                    asynchronous: true
                    width: height
                }

                Label {
                    property string dateTime: fullscreenPage.model.getField(fullscreenPage.currentIndex,
                                                                            FacebookImageCacheModel.DateTaken)
                    text: formattedTimestamp(dateTime)
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}

