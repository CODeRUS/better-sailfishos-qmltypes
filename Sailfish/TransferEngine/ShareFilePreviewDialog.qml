/****************************************************************************************
**
** Copyright (c) 2019 Jolla Ltd.
** Copyright (c) 2019 Open Mobile Platform LLC
** All rights reserved.
**
** License: Proprietary.
**
****************************************************************************************/
import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.FileManager 1.0
import Sailfish.TransferEngine 1.0
import org.nemomobile.thumbnailer 1.0

ShareDialog {
    id: root

    property alias shareItem: shareItem
    property alias remoteDirName: targetFolderLabel.text
    property alias remoteDirReadOnly: targetFolderLabel.readOnly
    property alias fileInfo: fileInfo

    property alias imageScaleVisible: scaleComboBox.visible
    property alias descriptionVisible: descriptionTextField.visible
    property alias descriptionPlaceholderText: descriptionTextField.placeholderText
    property alias metaDataSwitchVisible: metaDataSwitch.visible

    property real _scalePercent: 1.0

    FileInfo {
        id: fileInfo
        source: root.source
    }

    SailfishShare {
        id: shareItem

        source: root.source
        content: root.content
        serviceId: root.methodId
        mimeType: fileInfo.mimeType
        userData: {
            "description": descriptionTextField.text,
            "accountId": root.accountId,
            "scalePercent": root._scalePercent,
            "remoteDirName": root.remoteDirName,
        }
    }

    SilicaFlickable {
        id: flickable

        anchors.fill: parent
        contentHeight: root.isPortrait
                       ? settingsList.y + settingsList.height
                       : Math.max(preview.y + preview.height, settingsList.y + settingsList.height)

        DialogHeader {
            id: dialogHeader
            //: Title for page enabling user to share files
            //% "Share"
            acceptText: qsTrId("transferui-he-share_heading")
            spacing: 0
        }

        Thumbnail {
            id: preview

            anchors.top: dialogHeader.bottom
            width: root.isPortrait ? Screen.width : Screen.height / 3
            height: Screen.height / 3
            sourceSize.width: width
            sourceSize.height: height

            visible: status === Thumbnail.Ready
            fillMode: Thumbnail.PreserveAspectCrop
            clip: true
            mimeType: fileInfo.mimeType
            source: root.source
        }

        Column {
            id: settingsList

            anchors {
                left: root.isPortrait || !preview.visible ? parent.left : preview.right
                right: parent.right
                top: root.isPortrait && preview.visible ? preview.bottom : preview.top
            }

            FileInfoItem {
                bottomPadding: Theme.paddingLarge
                fileName: root.content && root.content.name ? root.content.name : fileInfo.fileName
                mimeType: root.content && root.content.type || fileInfo.mimeType
                fileSize: root.content && root.content.data && root.content.data.length
                          ? root.content.data.length
                          : fileInfo.fileName.length > 0 ? fileInfo.size : -1
            }

            TextField {
                id: descriptionTextField

                width: parent.width

                //: Image description
                //% "Description"
                placeholderText: qsTrId("transferui-la-description")
                label: placeholderText

                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: root.focus = true
            }

            ComboBox {
                id: scaleComboBox

                width: settingsList.width
                currentIndex: 3

                //: Image scale
                //% "Scale image"
                label: qsTrId("transferui-la-scale_image")

                menu: ContextMenu {
                    x: 0
                    width: scaleComboBox.width

                    //: Image scale is 25%
                    //% "25 %"
                    MenuItem { text: qsTrId("transferui-va-25_percent"); onClicked: root._scalePercent = 0.25 }
                    //: Image scale is 50%
                    //% "50 %"
                    MenuItem { text: qsTrId("transferui-va-50_percent"); onClicked: root._scalePercent = 0.5 }
                    //: Image scale is 75%
                    //% "75 %"
                    MenuItem { text: qsTrId("transferui-va-75_percent"); onClicked: root._scalePercent = 0.75  }
                    //: Image scale is original
                    //% "original"
                    MenuItem { text: qsTrId("transferui-va-original"); onClicked: root._scalePercent = 1 }
                }
            }

            TextSwitch {
                id: metaDataSwitch

                //: Include image metadata
                //% "Include metadata"
                text: qsTrId("transferui-me-include_metadata")
                height: implicitHeight + Theme.paddingLarge
                checked: !shareItem.metadataStripped
                onCheckedChanged: shareItem.metadataStripped = !checked
            }

            Column {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                visible: accountNameLabel.text.length > 0

                Label {
                    id: accountNameLabel

                    width: parent.width
                    truncationMode: TruncationMode.Fade
                    color: Theme.highlightColor
                    text: root.accountName
                }

                Label {
                    width: parent.width
                    color: Theme.secondaryHighlightColor
                    truncationMode: TruncationMode.Fade
                    font.pixelSize: Theme.fontSizeSmall
                    text: root.displayName
                    height: implicitHeight + Theme.paddingLarge
                }
            }

            TextField {
                id: targetFolderLabel

                width: parent.width
                visible: targetFolderLabel.text.length > 0 || !targetFolderLabel.readOnly
                readOnly: true
                color: readOnly ? Theme.highlightColor : Theme.primaryColor
                //% "Destination folder"
                label: qsTrId("transferui-la-destination_folder")
                placeholderText: label
            }
        }

        VerticalScrollDecorator {}
    }
}
