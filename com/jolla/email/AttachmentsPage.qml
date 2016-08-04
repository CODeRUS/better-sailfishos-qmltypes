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
            contentHeight: icon.height
            menu: menuComponent

            ListView.onRemove: animateRemoval()

            Thumbnail {
                id: icon
                z: -1
                x: Theme.horizontalPageMargin - Theme.paddingLarge
                visible: url != "" && status != Thumbnail.Null && status != Thumbnail.Error
                height: Theme.itemSizeLarge
                width: height
                anchors.verticalCenter: parent.verticalCenter
                sourceSize.width: width
                sourceSize.height: height
                source: url
                mimeType: mimeType
            }

            Image {
                id: defaultIcon
                x: Theme.horizontalPageMargin - Theme.paddingLarge
                visible: !icon.visible
                height: Theme.itemSizeLarge
                width: height
                anchors.verticalCenter: parent.verticalCenter
                sourceSize.width: width
                sourceSize.height: height
                source: "image://theme/icon-l-other?" + (highlighted ? Theme.highlightColor : Theme.primaryColor)
            }

            Label {
                id: titleLabel
                anchors {
                    left: icon.visible ? icon.right : defaultIcon.right
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: icon.visible ? icon.verticalCenter : defaultIcon.verticalCenter
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
