import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.socialcache 1.0
import com.jolla.gallery.extensions 1.0

FullscreenPhotoPage {
    id: fullscreenPage

    deletingAllowed: false

    delegate: CloudImage {
        id: delegateItem
        imageId: model.id
        accountId: model.accountId
        width: slideshowView.width
        height: slideshowView.height
        onRequestDownloadUrl: delegateItem.downloadWithAccessToken(model.imageUrl, accessToken)
    }
}
