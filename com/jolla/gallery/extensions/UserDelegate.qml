import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import org.nemomobile.socialcache 1.0
import com.jolla.gallery.extensions 1.0

BackgroundItem {
    id: delegateItem

    property string userId: model.id
    property alias slideshowModel: thumbnail.model
    property alias serviceIcon: thumbnail.serviceIcon
    property alias title: titleLabel.text

    height: thumbnail.height

    Label {
        id: titleLabel
        elide: Text.ElideRight
        font.pixelSize: Theme.fontSizeLarge
        color: delegateItem.down ? Theme.highlightColor : Theme.primaryColor
        anchors {
            right: thumbnail.left
            rightMargin: Theme.paddingLarge
            verticalCenter: parent.verticalCenter
        }
    }

    SlideshowIcon {
        id: thumbnail
        anchors.left: parent.horizontalCenter
    }

    Label {
        anchors {
            right: parent.right
            leftMargin: Theme.horizontalPageMargin
            left: thumbnail.right
            verticalCenter: parent.verticalCenter
        }
        text: model.dataCount
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeLarge
    }
}
