/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Valerio Valerio <valerio.valerio@jolla.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import org.nemomobile.thumbnailer 1.0

Page {
    property alias attachmentFiles: listView.model
    property Component contentPicker

    signal addAttachments

    allowedOrientations: Orientation.All

    SilicaListView {
        id: listView

        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                //% "Add new attachment"
                text: qsTrId("jolla-email-me-add_new_attachment")
                onClicked: addAttachments()
            }
            MenuItem {
                visible: attachmentFiles.count > 0
                // Defined in email composer page
                text: qsTrId("jolla-email-me-remove_all_attachments", attachmentFiles.count)
                onDelayedClick: attachmentFiles.clear()
            }
        }

        header: PageHeader {
            title: attachmentFiles.count == 0
                     //% "No Attachments"
                   ? qsTrId("jolla-email-he-no_attachments")
                     //: Singular: 1 attachment (or one as text), plural: X Attachments (X the number)
                     //% "%n Attachments"
                   : qsTrId("jolla-email-he-attachments_page", attachmentFiles.count)
        }

        delegate: ListItem {
            contentHeight: Theme.itemSizeMedium
            menu: menuComponent

            ListView.onRemove: animateRemoval()

            Rectangle {
                id: iconContainer
                width: height
                height: parent.height

                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
                    GradientStop { position: 1.0; color: "transparent" }
                }

                Thumbnail {
                    id: thumbnail
                    visible: url != "" && status != Thumbnail.Null && status != Thumbnail.Error
                    height: defaultIcon.height
                    width: height
                    anchors.centerIn: parent
                    sourceSize.width: width
                    sourceSize.height: height
                    source: url
                    mimeType: mimeType
                }

                Image {
                    id: defaultIcon
                    visible: !thumbnail.visible
                    anchors.centerIn: parent
                    source: Theme.iconForMimeType(mimeType) + (highlighted ? "?" + Theme.highlightColor : "")
                }
            }

            Label {
                id: attachmentTitleLabel
                anchors {
                    left: iconContainer.right
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: iconContainer.verticalCenter
                    verticalCenterOffset: -attachmentSizeLabel.height/2
                }
                text: title
                truncationMode: TruncationMode.Fade
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            Label {
                id: attachmentSizeLabel
                anchors {
                    left: iconContainer.right
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    top: attachmentTitleLabel.bottom
                }
                font.pixelSize: Theme.fontSizeExtraSmall
                text: Format.formatFileSize(fileSize)
                truncationMode: TruncationMode.Fade
                color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            }

            Component {
                id: menuComponent

                ContextMenu {
                    MenuItem {
                        // Defined in email composer page
                        text: qsTrId("jolla-email-me-remove_all_attachments", 1)
                        onClicked: {
                            attachmentFiles.remove(model.index)
                        }
                    }
                }
            }
        }

        ViewPlaceholder {
            enabled: attachmentFiles.count == 0

            //% "Pull down to add attachments"
            text: qsTrId("email-la_no_attachments_viewplace_text")
        }

        VerticalScrollDecorator {}
    }
}
