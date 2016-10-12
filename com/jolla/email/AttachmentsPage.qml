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
    id: attachmentsPage

    property QtObject attachmentFiles
    property Component contentPicker

    function modifyAttachments() {
        var picker = pageStack.push(contentPicker, { selectedContent: attachmentFiles })
        picker.selectedContentChanged.connect(function() {
            attachmentFiles.clear()
            for(var i=0; i < picker.selectedContent.count; ++i) {
                attachmentFiles.append(picker.selectedContent.get(i))
            }
        })
    }

    SilicaListView {
        id: listView
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: parent.height

        PullDownMenu {
            MenuItem {
                id: addItem
                //: Add new attachment
                //% "Add new attachment"
                text: qsTrId("jolla-email-me-add_new_attachment")
                onClicked: modifyAttachments()
            }
            MenuItem {
                id: removeItem
                visible: attachmentFiles.count > 0
                // Defined in email composer page
                text: qsTrId("jolla-email-me-remove_all_attachments", attachmentFiles.count)
                onClicked: {
                    attachmentFiles.clear()
                }
            }
        }

        header: PageHeader {
            //: Attachments
            //% "Attachments"
            title: qsTrId("jolla-email-he-attachments_page")
        }

        model: attachmentFiles

        delegate: ListItem {
            id: item
            width: parent.width
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
                    id: icon
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
                    visible: !icon.visible
                    anchors.centerIn: parent
                    source: Theme.iconForMimeType(mimeType) + (highlighted ? "?" + Theme.highlightColor : "")
                }
            }

            Label {
                id: titleLabel
                anchors {
                    left: iconContainer.right
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: iconContainer.verticalCenter
                }
                text: title
                truncationMode: TruncationMode.Fade
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
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

        VerticalScrollDecorator {}
    }
}
