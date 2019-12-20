import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import org.nemomobile.social 1.0
import org.nemomobile.socialcache 1.0
import Sailfish.Gallery 1.0
import com.jolla.gallery.extensions 1.0

FullscreenContentPage {
    id: root

    property alias model: slideShow.model
    property alias delegate: slideShow.delegate
    property alias overlay: overlay
    property SlideshowView slideshowView: slideShow
    property int currentIndex: -1
    property int currentAccountId
    property SocialImageCache downloader
    property AccessTokensProvider accessTokensProvider
    property alias currentSource: overlay.source
    property string accessToken
    property bool connectedToNetwork

    // Private properties
    property int _toBeDeletedIndex: -1
    property int _toBeDeletedAccountId

    signal deletePhoto(int index, string accessToken)

    allowedOrientations: window.allowedOrientations
    Component.onCompleted: slideshowView.positionViewAtIndex(currentIndex, PathView.Center)

    Connections {
        target: accessTokensProvider
        onAccessTokenRetrieved: {
            if (_toBeDeletedIndex >= 0 && _toBeDeletedIndex < slideShow.count && accountId == _toBeDeletedAccountId) {
                root.deletePhoto(_toBeDeletedIndex, accessToken)
                _toBeDeletedIndex = -1
                if (_toBeDeletedIndex === currentIndex) pageStack.pop()
            }
        }
    }

    // Element for handling the actual flicking and image buffering
    SlideshowView {
        id: slideShow

        interactive: model.count > 1
        // XXX Qt5 Port - workaround PathView bug
        pathItemCount: 3
        itemWidth: width
        itemHeight: height
    }

    GalleryOverlay {
        id: overlay

        onRemove: {
            var index = currentIndex
            var accountId = currentAccountId
            //: Delete an image
            //% "Deleting"
            remorseAction( qsTrId("jolla_gallery_extensions-la-deleting"), function() {
                _toBeDeletedIndex = index
                _toBeDeletedAccountId = accountId
                accessTokensProvider.requestAccessToken(accountId)
            })
        }

        isImage: true
        detailsButton.visible: true
        detailsButton.onClicked: pageStack.animatorPush("DetailsPage.qml", {model: slideShow.currentItem.modelItem})

        editingAllowed: false
        sharingAllowed: false
        anchors.fill: parent
        z: model.count + 100

        Private.DismissButton {}
    }
}
