import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import org.nemomobile.socialcache 1.0
import com.jolla.gallery.extensions 1.0

UsersPage {
    id: root
    socialNetwork: SocialSync.OneDrive
    dataType: SocialSync.Images
    usersModel: OneDriveImageCacheModel {
        Component.onCompleted: refresh()
        type: OneDriveImageCacheModel.Users
        onCountChanged: {
            if (count === 0) {
                // no users left, return to gallery main level
                pageStack.pop(null)
            }
        }
    }
    userDelegate: UserDelegate {
        id: delegateItem
        serviceIcon: "image://theme/graphic-service-onedrive"
        title: model.title
        slideshowModel: OneDriveImageCacheModel {
            Component.onCompleted: refresh()
            type: OneDriveImageCacheModel.Images
            nodeIdentifier: delegateItem.userId == "" ? "" : "user-" + delegateItem.userId
            downloader: OneDriveImageDownloader
        }
        onClicked: {
            window.pageStack.push(Qt.resolvedUrl("OneDriveAlbumsPage.qml"),
                                  {"userId": delegateItem.userId,
                                   "title": root.title})
        }
    }
}
