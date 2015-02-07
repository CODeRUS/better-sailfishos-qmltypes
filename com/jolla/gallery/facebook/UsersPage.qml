import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import org.nemomobile.socialcache 1.0

Page {
    id: root
    allowedOrientations: window.allowedOrientations

    SilicaListView {
        id: view
        anchors.fill: parent
        header: PageHeader {}
        model: FacebookImageCacheModel {
            id: fbUsers
            Component.onCompleted: refresh()
            type: FacebookImageCacheModel.Users
            onCountChanged: {
                if (count === 0) {
                    // no users left, return to gallery main level
                    pageStack.pop(null)
                }
            }
        }

        delegate: BackgroundItem {
            id: delegateItem
            property string userId: model.facebookId
            anchors {
                left: parent.left
                right: parent.right
            }
            height: thumbnail.height

            Label {
                id: titleLabel
                elide: Text.ElideRight
                font.pixelSize: Theme.fontSizeLarge
                text: model.title
                color: delegateItem.down ? Theme.highlightColor : Theme.primaryColor
                anchors {
                    right: thumbnail.left
                    rightMargin: Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
            }

            SlideshowIcon {
                id: thumbnail
                // Between 7 and 14 s, it is funnier when it is random
                timerInterval: 7000 +  Math.floor((Math.random() * 7000));
                anchors.left: parent.horizontalCenter
                opacity: delegateItem.down ? 0.5 : 1
                model: FacebookImageCacheModel {
                    Component.onCompleted: refresh()
                    type: FacebookImageCacheModel.Images
                    nodeIdentifier: delegateItem.userId == "" ? "" : "user-" + delegateItem.userId
                    downloader: FacebookImageDownloader
                }
            }

            Label {
                id: countLabel
                anchors {
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    left: thumbnail.right
                    verticalCenter: parent.verticalCenter
                }
                text: model.dataCount
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }

            onClicked: {
                window.pageStack.push(Qt.resolvedUrl("AlbumsPage.qml"),
                                      {"userId": delegateItem.userId})
            }
        }

        SyncHelper {
            socialNetwork: SocialSync.Facebook
            dataType: SocialSync.Images
            onLoadingChanged: {
                if (!loading) {
                    fbUsers.refresh()
                }
            }
            onProfileDeleted: {
                if (window.pageStack.currentPage === root) {
                    var page = pageStack.currentPage
                    var prevPage = pageStack.previousPage(page)
                    while (prevPage) {
                        page = prevPage
                        prevPage = pageStack.previousPage(prevPage)
                    }
                    pageStack.pop(page)
                }
            }
        }
    }
}
