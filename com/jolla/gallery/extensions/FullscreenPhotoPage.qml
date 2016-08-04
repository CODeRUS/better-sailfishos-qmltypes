import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Ambience 1.0
import org.nemomobile.social 1.0
import org.nemomobile.socialcache 1.0
import com.jolla.gallery.extensions 1.0

SplitViewPage {
    id: fullscreenPage

    property alias model: _slideshowView.model
    property alias delegate: _slideshowView.delegate
    property alias header: listView.header
    property SlideshowView slideshowView: _slideshowView
    property int currentIndex: -1
    property int currentAccountId
    property SocialImageCache downloader
    property AccessTokensProvider accessTokensProvider
    property string currentSource
    property string accessToken
    property bool connectedToNetwork

    // Private properties
    property int _toBeDeletedIndex: -1
    property int _toBeDeletedAccountId

    signal deletePhoto(int index, string accessToken)

    allowedOrientations: window.allowedOrientations
    Component.onCompleted: slideshowView.positionViewAtIndex(currentIndex, PathView.Center)

    Connections {
        target: fullscreenPage.accessTokensProvider
        onAccessTokenRetrieved: {
            if (fullscreenPage._toBeDeletedIndex >= 0 && accountId == fullscreenPage._toBeDeletedAccountId) {
                fullscreenPage.deletePhoto(_toBeDeletedIndex, accessToken)
                _toBeDeletedIndex = -1
            }
        }
    }

    // The top part of the split view, plus pulley menu for creating ambience and add a new comment
    // List also displays all the comments if there are any
    background: SilicaListView {
        id: listView
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                //: The user can select this option to delete picture
                //% "Delete picture"
                text: qsTrId("jolla_gallery_extensions-me-delete_picture")
                visible: (fullscreenPage.currentSource != ""
                           && pictureDeletionRemorse.state !== "active"
                           && fullscreenPage._toBeDeletedIndex < 0)
                onClicked: _deletePicture(fullscreenPage.currentIndex, fullscreenPage.currentAccountId)
            }
            MenuItem {
                //: The user can select this option to create Ambience from the image
                //% "Create ambience"
                text: qsTrId("jolla_gallery_extensions-me-create_ambience")
                visible: fullscreenPage.currentSource != ""
                onClicked: Ambience.source = fullscreenPage.currentSource
            }
        }

        VerticalScrollDecorator {}
    }

    // Element for handling the actual flicking and image buffering
    SlideshowView {
        id: _slideshowView

        property Item currentItem

        interactive: model.count > 1
        onCurrentIndexChanged: fullscreenPage.currentIndex = currentIndex
    }

    RemorsePopup {
        id: pictureDeletionRemorse
    }

    function _deletePicture(index, accountId) {
        //: Deleting this picture in 5 seconds
        //% "Removing picture"
        pictureDeletionRemorse.execute(qsTrId("jolla_gallery_extensions-la-remove_picture"),
                                       function() { fullscreenPage._toBeDeletedIndex = index; fullscreenPage._toBeDeletedAccountId = accountId; fullscreenPage.accessTokensProvider.requestAccessToken(accountId) } )
    }
}
