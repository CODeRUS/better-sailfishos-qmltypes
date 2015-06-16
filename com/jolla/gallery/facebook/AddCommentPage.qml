import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.social 1.0

Page {
    property string nodeIdentifier
    property alias commentsModel: commentsList.model
    property FacebookPhoto photoItem
    property string photoUserId

    allowedOrientations: window.allowedOrientations

    function formattedTimestamp(isostr) {
        var parts = isostr.match(/\d+/g);
        // Make sure to use UTC time.
        var dateTime = new Date(Date.UTC(parts[0], parts[1] - 1, parts[2], parts[3], parts[4], parts[5]))
        var today = new Date;

        // return time, if it's today
        if (dateTime.getFullYear() === today.getFullYear() &&
            dateTime.getMonth() === today.getMonth() &&
            dateTime.getDay() === today.getDay()) {
            return Format.formatDate(dateTime, Formatter.TimepointRelative)
        }

        return Format.formatDate(dateTime, Formatter.DurationElapsed)
    }

    Connections {
        target: photoItem
        onStatusChanged: {
            if (photoItem.status === Facebook.Idle) {
                if (commentsModel.count > 0) {
                    commentsModel.loadNext()
                } else {
                    commentsModel.repopulate()
                }
            }
        }
    }

    SilicaListView {
        id: commentsList
        width: parent.width
        spacing: Theme.paddingMedium
        anchors.fill: parent

        //: "Facebook album comments page title
        //% "Comments"
        header: PageHeader { title: qsTrId("jolla-gallery-facebook-he-comments") }

        delegate: Item {
            id: commentDelegate
            property bool _showDelegate: commentsList.count

            width: commentsList.width
            height: commentFrom.paintedHeight
                    + commentText.paintedHeight
                    + likeText.paintedHeight
                    + 3 * Theme.paddingSmall

            opacity: _showDelegate ? 1 : 0
            Behavior on opacity { FadeAnimation {} }

            Rectangle {
                id: avatarPlaceholder
                width: Theme.itemSizeSmall
                height: Theme.itemSizeSmall
                color: Theme.highlightColor
                opacity: 0.5
                x: Theme.horizontalPageMargin
            }

            Image {
                id: avatar
                // Fetch the avatar from the constructed url
                source: _showDelegate ? "http://graph.facebook.com/"+ model.contentItem.from.objectIdentifier + "/picture" : ""
                clip: true
                anchors.fill: avatarPlaceholder
                fillMode: Image.PreserveAspectCrop
                smooth: true
            }

            Column {
                id: commentColumn
                spacing: Theme.paddingSmall
                anchors {
                    left: avatar.right
                    leftMargin: Theme.paddingMedium
                    top: avatar.top
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }

                Label {
                    id: commentText
                    text: _showDelegate ? model.contentItem.message : ""
                    width: parent.width
                    font.pixelSize: Theme.fontSizeExtraSmall
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.Wrap
                }

                Row {
                    spacing: Theme.paddingSmall

                    Label {
                        id: commentFrom
                        text: _showDelegate ? model.contentItem.from.objectName : ""
                        color: Theme.secondaryColor
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignTop
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }

                    Label {
                        id: createdTime
                        text: _showDelegate ? formattedTimestamp(model.contentItem.createdTime) : ""
                        color: Theme.secondaryHighlightColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
            }

            Label {
                id: likeCount
                visible: _showDelegate ? model.contentItem.likeCount > 0 : ""
                text: model.contentItem.likeCount
                color: Theme.highlightColor
                horizontalAlignment: Text.AlignRight
                font.pixelSize: Theme.fontSizeExtraSmall
                anchors {
                    top: commentColumn.bottom
                    topMargin: Theme.paddingSmall
                    right: commentColumn.left
                    rightMargin: Theme.paddingMedium
                }
            }

            Label {
                id: likeText
                //: Number of likes for the comment
                //% "Like"
                property string like: qsTrId("jolla_gallery_facebook-la-single-like-for-comment")
                //% "Likes"
                property string likes: qsTrId("jolla_gallery_facebook-la-number-of-likes-for-comment")
                text: _showDelegate
                        ? model.contentItem.likeCount > 1 ? likes : like
                        : ""
                visible: likeCount.visible
                font.pixelSize: Theme.fontSizeExtraSmall
                anchors {
                    top: commentColumn.bottom
                    topMargin: Theme.paddingSmall
                    left: commentColumn.left
                }
            }
        }

        footer: Item {
            height: addCommentTextField.height
            width: commentsList.width

            TextArea {
                id: addCommentTextField
                width: parent.width - (sendButton.paintedWidth + Theme.paddingSmall)
                height: Math.max(Theme.itemSizeMedium, implicitHeight)
                //% "Write comment"
                label: qsTrId("jolla_gallery_facebook-la-write-comment-page")

                //% "Write a comment"
                placeholderText: qsTrId("jolla_gallery_facebook-ph-add-comment-page-ph-description")
            }

            Label {
                id: sendButton
                //: Send comment button in FB album's comment page
                //% "Send"
                text: qsTrId("jolla-gallery-facebook-bt-send-comment")
                visible: addCommentTextField.text.length > 0
                anchors {
                    left: addCommentTextField.right
                    bottom: addCommentTextField.bottom
                    bottomMargin: Theme.paddingLarge
                }

                MouseArea {
                    enabled: sendButton.visible
                    anchors.fill: parent
                    onClicked: {
                        if (addCommentTextField.text != "") {
                            photoItem.uploadComment(addCommentTextField.text)
                            addCommentTextField.focus = false
                            addCommentTextField.text = ""
                        }
                    }
                }
            }
        }
        VerticalScrollDecorator {}
    }
}
