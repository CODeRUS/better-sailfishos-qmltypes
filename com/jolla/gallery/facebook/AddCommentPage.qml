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
        var parts = isostr.match(/\d+/g)
        // Make sure to use UTC time.
        var dateTime = new Date(Date.UTC(parts[0], parts[1] - 1, parts[2], parts[3], parts[4], parts[5]))
        var today = new Date

        // return time, if it's today
        if (dateTime.getFullYear() === today.getFullYear() &&
            dateTime.getMonth() === today.getMonth() &&
            dateTime.getDate() === today.getDate()) {
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

        spacing: Theme.paddingMedium
        anchors.fill: parent
        currentIndex: -1
        focus: true

        //: "Facebook album comments page title
        //% "Comments"
        header: PageHeader { title: qsTrId("jolla-gallery-facebook-he-comments") }

        ViewPlaceholder {
            //% "Error loading comments"
            text: qsTrId("jolla-gallery-facebook-la-error_loading_comments")
            enabled: commentsModel.count === 0 && (commentsModel.status === SocialNetwork.Error || commentsModel.status === SocialNetwork.Invalid)
        }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: commentsModel.count === 0 && (commentsModel.status === SocialNetwork.Initializing || commentsModel.status === SocialNetwork.Busy)
        }

        delegate: Item {
            property bool _showDelegate: commentsList.count

            width: commentsList.width
            height: (likeCount.visible ? (likeCount.y + likeCount.height) : (commentColumn.y + commentColumn.height))
                    + Theme.paddingSmall
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
                source: _showDelegate ? "http://graph.facebook.com/v2.6/"+ model.contentItem.from.objectIdentifier + "/picture" : ""
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
                    rightMargin: Theme.horizontalPageMargin
                }

                Label {
                    text: _showDelegate ? model.contentItem.message : ""
                    width: parent.width
                    font.pixelSize: Theme.fontSizeExtraSmall
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.Wrap
                }

                Flow {
                    width: parent.width
                    spacing: Theme.paddingSmall

                    Label {
                        text: _showDelegate ? model.contentItem.from.objectName : ""
                        color: Theme.secondaryColor
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignTop
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }

                    Label {
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
                text: _showDelegate
                        ? //: Text at the right side of like count, should have plural handling for like vs likes.
                          //% "likes"
                          qsTrId("jolla_gallery_facebook-la-number-of-likes-for-comment", model.contentItem.likeCount)
                        : ""
                visible: likeCount.visible
                font.pixelSize: Theme.fontSizeExtraSmall
                anchors {
                    baseline: likeCount.baseline
                    left: commentColumn.left
                }
            }
        }

        footer: Item {
            height: addCommentTextField.height
            width: commentsList.width

            TextArea {
                id: addCommentTextField

                //% "Write comment"
                label: qsTrId("jolla_gallery_facebook-la-write-comment-page")
                placeholderText: label
                anchors { left: parent.left; right: buttonArea.left }
                focus: true
            }

            MouseArea {
                id: buttonArea
                anchors {
                    top: buttonText.top
                    topMargin: -Theme.paddingLarge
                    leftMargin: -Theme.paddingLarge - Math.max(0, Theme.itemSizeSmall - buttonText.width)
                    left: buttonText.left
                    right: parent.right
                    bottom: parent.bottom
                }
                enabled: addCommentTextField.text.length > 0
                onClicked: {
                    if (addCommentTextField.text != "") {
                        photoItem.uploadComment(addCommentTextField.text)
                        addCommentTextField.focus = false
                        addCommentTextField.text = ""
                    }
                }
            }

            Label {
                id: buttonText
                anchors {
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: addCommentTextField.top
                    verticalCenterOffset: addCommentTextField.textVerticalCenterOffset + (addCommentTextField._editor.height - height)
                }

                font.pixelSize: Theme.fontSizeSmall
                color: !buttonArea.enabled ? Theme.secondaryColor
                                           : (buttonArea.pressed ? Theme.highlightColor
                                                                 : Theme.primaryColor)

                //: Send comment button in Facebook album's comment page
                //% "Send"
                text: qsTrId("jolla-gallery-facebook-bt-send-comment")
            }
        }
        VerticalScrollDecorator {}
    }
}
