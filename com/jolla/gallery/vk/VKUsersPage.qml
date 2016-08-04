import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import org.nemomobile.socialcache 1.0
import com.jolla.gallery.extensions 1.0

UsersPage {
    id: root
    socialNetwork: SocialSync.VK
    dataType: SocialSync.Images
    usersModel: VKImageCacheModel {
        Component.onCompleted: refresh()
        type: VKImageCacheModel.Users
        onCountChanged: {
            if (count === 0) {
                // no users left, return to gallery main level
                pageStack.pop(null)
            }
        }
    }
    userDelegate: UserDelegate {
        id: delegateItem
        property int accountId: model.accountId
        userId: model.userId
        title: model.text
        serviceIcon: "image://theme/graphic-service-vk"
        slideshowModel: VKImageCacheModel {
            Component.onCompleted: refresh()
            type: VKImageCacheModel.Images
            nodeIdentifier: constructNodeIdentifier(delegateItem.accountId, delegateItem.userId, "", "")
            downloader: VKImageDownloader
        }
        onClicked: {
            window.pageStack.push(Qt.resolvedUrl("VKAlbumsPage.qml"),
                                  {"userId": delegateItem.userId,
                                   "accountId": delegateItem.accountId,
                                   "title": root.title})
        }
    }
}
