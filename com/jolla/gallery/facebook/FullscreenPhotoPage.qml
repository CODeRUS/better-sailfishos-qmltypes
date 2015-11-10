import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Ambience 1.0
import com.jolla.gallery.facebook 1.0
import org.nemomobile.social 1.0
import org.nemomobile.socialcache 1.0

SplitViewPage {
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

    // The following handlers make the Facebook elements to fetch new data. The data is being fetched
    // only when a split mode is active. This way we decrease network load and don't request any
    // data which user is not interested in.
    onOpenedChanged: {
        fetchData()
    }

    Component.onCompleted: {
        updateAccessToken()
        slideshowView.positionViewAtIndex(currentIndex, PathView.Center)
    }


    onCurrentIndexChanged: {
        updateAccessToken()
        if (!opened) {
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
        var parts = isostr.match(/\d+/g);
        var fixedDate = new Date(Date.UTC(parts[0], parts[1] - 1, parts[2], parts[3], parts[4], parts[5]))
        return Format.formatDate(fixedDate, Formatter.TimepointRelative)
    }

    // Returns string formatted e.g. "You, Mike M and 3 others like this
    function likeInformation()
    {
        // Not very pretty code but localization and how this message
        // is expressed requires quite many variations
        var isLikedByPhotoUser = photoAndLikesModel.node.liked
        var photoUserName = ""
        var users =  new Array
        for (var i=0;  i < photoAndLikesModel.count; i++) {
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
                //% "You, %1 and %2 others like this"
                return qsTrId("jolla_gallery_facebook-la-you-and-multiple-friend-like-this")
                    .arg(users[0])
                    .arg(photoAndLikesModel.likesCount - 2)
            } else {
                //% "%1 and %2 and %3 others like this"
                return qsTrId("jolla_gallery_facebook-la-multiple-friend-like-this")
                    .arg(users[0])
                    .arg(users[1])
                    .arg(photoAndLikesModel.likesCount - 2)
            }
        }
        // Return an empty string for 0 likes
        return ""
    }

    Connections {
        target: fullscreenPage.accessTokensProvider
        onAccessTokenRetrieved: if (fullscreenPage.model.getField(currentIndex, FacebookImageCacheModel.AccountId) == accountId) {
            facebook.accessToken = accessToken
            if (fullscreenPage.opened) {
                fullscreenPage.fetchData()
            }
        }
    }

    Facebook {id: facebook}

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
            photoAndLikesModel.likeInfo =  ""
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

    // This timer is here to make data fetching little more intelligent. Data is usually fetched
    // from FB only when user taps view to split mode and/or is flicking images while the split
    // mode is on. This is the third case, when user flicks and split mode is off data is not fetched
    // unless user stops flicking for 2 seconds. This might mean that user is interested in that image
    // and will soon split the view to fetch data, but in this case the data will already be there.
    Timer {
        id: imageFlickTimer
        property string photoId
        interval: 2000
        onTriggered: {
            if (photoId == _currentPhotoId && !fullscreenPage.open) {
                fetchData()
            }
        }
    }

    // The top part of the split view, plus pulley menu for creating ambience and add a new comment
    // List also displays all the comments if there are any
    background: SilicaListView {
        id: listView

        PullDownMenu {

            MenuItem {
                //: The user can select this option to create Ambience from the image
                //% "Create ambience"
                text: qsTrId("jolla_gallery_facebook-me-create_ambience")
                onClicked: {
                    Ambience.source = fullscreenPage.model.getField(fullscreenPage.currentIndex, FacebookImageCacheModel.Image)
                }
            }
        }

        anchors.fill: parent

        header: Row {

            spacing: Theme.paddingLarge
            height: Theme.itemSizeLarge
            anchors {
                right: parent.right
                rightMargin: _rightMargin
            }

            Image {
                opacity:photoAndLikesModel.loading ? 0.5 : 1
                source: "image://theme/icon-s-like" + "?" + Theme.highlightColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                opacity:photoAndLikesModel.loading ? 0.5 : 1
                color: Theme.highlightColor
                text: photoAndLikesModel.likesCount == -1 ? "" : photoAndLikesModel.likesCount
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.paddingLarge
            }

            Image {
                opacity:photoAndLikesModel.loading ? 0.5 : 1
                source: "image://theme/icon-s-chat" + "?" + Theme.highlightColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                opacity:photoAndLikesModel.loading ? 0.5 : 1
                color: Theme.highlightColor
                text: photoAndLikesModel.commentsCount == -1 ? "" : photoAndLikesModel.commentsCount
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.paddingLarge
            }
        }

        model: VisualItemModel {

            Label {
                id: likesInfo
                property int maxHeight: wrapMode == Text.NoWrap ? Theme.itemSizeSmall / 2 : Theme.itemSizeSmall
                text: photoAndLikesModel.likeInfo
                wrapMode: width < paintedWidth ? Text.Wrap : Text.NoWrap
                verticalAlignment: Text.AlignTop
                x: Theme.horizontalPageMargin
                height: text == "" ? 0 : maxHeight
                width: listView.width - x - _rightMargin
                opacity: text == "" ? 0 : 1
                font.pixelSize: Theme.fontSizeExtraSmall
                Behavior on height { FadeAnimation { property: "height" } }
                Behavior on opacity { FadeAnimation {} }
            }

            Label {
                //% "No title"
                property string unknownNameStr: qsTrId("jolla_gallery_facebook-la-unnamed_photo")
                property string photoNameStr: fullscreenPage.model.getField(fullscreenPage.currentIndex,
                                                                            FacebookImageCacheModel.Title)
                text: photoNameStr == "" ? unknownNameStr : photoNameStr
                width: listView.width - x - _rightMargin
                wrapMode: Text.Wrap
                x: Theme.horizontalPageMargin
                font.pixelSize: Theme.fontSizeExtraSmall
            }

            Row {
                x: Theme.horizontalPageMargin
                y: Theme.paddingSmall
                spacing: Theme.paddingSmall

                Image {
                    id: fbIcon
                    source: "image://theme/icon-s-service-facebook"
                    height: Theme.fontSizeExtraSmall
                    width: height
                    asynchronous: true
                }

                Label {
                    property string dateTime: fullscreenPage.model.getField(fullscreenPage.currentIndex,
                                                                            FacebookImageCacheModel.DateTaken)
                    text: formattedTimestamp(dateTime)
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Item {
                width: listView.width
                height: childrenRect.height

                BackgroundItem {
                    id: likeItem

                    opacity: photoAndLikesModel.loading ? 0.5 : 1
                    enabled: !photoAndLikesModel.loading
                    Behavior on opacity { FadeAnimation {} }
                    width: listView.width / 2
                    Row {
                        x: Theme.horizontalPageMargin
                        height: parent.height
                        spacing: Theme.paddingLarge

                        Image {
                            source: "image://theme/icon-s-like"
                                    + (likeItem.highlighted ? "?" + Theme.highlightColor : "")
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            //: Like text for FB album
                            //% "Like"
                            property string like: qsTrId("jolla_gallery_facebook-la-album_like")
                            //: Unlike text for FB album
                            //% "Unlike"
                            property string unlike: qsTrId("jolla_gallery_facebook-la-album_unlike")
                            text: photoAndLikesModel.liked ? unlike : like
                            width: paintedWidth
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: likeItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        }
                    }
                    onClicked: {
                        if (photoAndLikesModel.node.liked) {
                            photoAndLikesModel.node.unlike()
                        } else {
                            photoAndLikesModel.node.like()
                        }
                    }
                }

                BackgroundItem {
                    id: commentItem

                    opacity: photoAndLikesModel.loading ? 0.5 : 1
                    enabled: !photoAndLikesModel.loading
                    width: listView.width / 2
                    x: listView.width / 2
                    Row {
                        height: parent.height
                        spacing: Theme.paddingLarge
                        Image {
                            source: "image://theme/icon-s-chat"
                                    + (commentItem.highlighted ? "?" + Theme.highlightColor : "")
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            //: Comment text for FB album
                            //% "Comment"
                            text: qsTrId("jolla_gallery_facebook-la-album-comment")
                            width: paintedWidth
                            color: commentItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                    onClicked: {
                        // We load the comments when we need them
                        commentsModel.nodeIdentifier = fullscreenPage._currentPhotoId
                        commentsModel.repopulate()
                        pageStack.push(Qt.resolvedUrl("AddCommentPage.qml"), {
                                           nodeIdentifier: _currentPhotoId,
                                           commentsModel: commentsModel,
                                           photoItem: photoAndLikesModel.node,
                                           photoUserId: _currentPhotoUserId
                                          })
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }

    // Element for handling the actual flicking and image buffering
    SlideshowView {
        id: slideshowView

        property Item currentItem

        model: fullscreenPage.model
        currentIndex: fullscreenPage.currentIndex
        onCurrentIndexChanged: fullscreenPage.currentIndex = currentIndex
        interactive: model.count > 1

        delegate: MouseArea {
            id: delegate
            property bool isPagePortrait: fullscreenPage.isPortrait
            property bool isSplitActive: fullscreenPage.open
            width: slideshowView.width
            height: slideshowView.height
            opacity: Math.abs(x) <= slideshowView.width ? 1.0 - (Math.abs(x) / slideshowView.width) : 0

            onIsSplitActiveChanged: photo.updateScale()
            onIsPagePortraitChanged: photo.updateScale()
            onClicked: fullscreenPage.open = !fullscreenPage.open

            // Pass information about the current item to the top level view in a case
            // user wants to check comments or add a new one, like etc..
            property bool moving: slideshowView.moving
            property bool isCurrentItem: PathView.isCurrentItem
            onIsCurrentItemChanged: {
                if (isCurrentItem) {
                    fullscreenPage._currentPhotoId = model.facebookId
                    fullscreenPage._currentPhotoUserId = model.userId
                }
            }


            Image {
                id: photo
                property real scaleFactor

                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                source: model.image
                asynchronous: true
                width: implicitWidth * scaleFactor
                height: implicitHeight * scaleFactor
                Behavior on scaleFactor { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }}

                onStatusChanged: {
                    if (status == Image.Ready) {
                        updateScale()
                    }
                }

                function updateScale() {
                    if (delegate.isSplitActive) {
                        var visibleWidth = delegate.isPagePortrait ? fullscreenPage.width : fullscreenPage.width * .5
                        var visibleHeight = delegate.isPagePortrait ? fullscreenPage.height * .5 : fullscreenPage.height
                        scaleFactor = Math.max(visibleWidth / photo.implicitWidth,
                                               visibleHeight / photo.implicitHeight)
                    } else {
                        scaleFactor = Math.min(fullscreenPage.width / photo.implicitWidth,
                                               fullscreenPage.height / photo.implicitHeight)
                    }
                }
            }
        }
    }
}
