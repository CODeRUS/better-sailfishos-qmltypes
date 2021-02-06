/****************************************************************************************
**
** Copyright (c) 2013 - 2019 Jolla Ltd.
** Copyright (c) 2020 Open Mobile Platform LLC
** All rights reserved.
**
** License: Proprietary.
**
****************************************************************************************/
import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0
import org.nemomobile.thumbnailer 1.0
import org.nemomobile.transferengine 1.0

Page {
    id: transfersPage

    property bool clearingTransfers

    function statusText(transferType, status, fileSize, transferDate) {
        switch(status) {
        case TransferModel.NotStarted:
            //% "Waiting"
            return qsTrId("transferui-la_transfer_waiting")
        case TransferModel.TransferStarted:
            return transferTypeText(transferType)
        case TransferModel.TransferFinished:
        case TransferModel.TransferInterrupted:
        case TransferModel.TransferCanceled:
            // return size and date, separated by a pullet point
            var s = fileSize > 0 ? Format.formatFileSize(fileSize) + " \u2022 " : ""
            if (status === TransferModel.TransferInterrupted) {
                //% "Failed"
                s += qsTrId("transferui-la_transfer_failed")
                s += " \u2022 "
                s += Format.formatDate(transferDate, Formatter.TimepointRelativeCurrentDay)
            } else if (status === TransferModel.TransferCanceled) {
                //% "Stopped"
                s += qsTrId("transferui-la-transfer_stopped")
            } else {
                s += Format.formatDate(transferDate, Formatter.TimepointRelativeCurrentDay)
            }
            return s
        }
        //% "Unknown"
        return qsTrId("transferui-la-transfer_unknown")
    }

    function transferTypeText(transferType) {
        switch (transferType) {
        case TransferModel.Sync:
            //% "Syncing"
            return qsTrId("transferui-la_transfer_syncing")
        case TransferModel.Download:
            //% "Downloading"
            return qsTrId("transferui-la_transfer_downloading")
        case TransferModel.Upload:
            //% "Uploading"
            return qsTrId("transferui-la_transfer_uploading")
        }
        return ""
    }

    function transferIcon(transferType, highlight) {
        // TODO: How we figure out if upload/download is from device2device e.g. BT.
        var imgSource = ""
        switch (transferType) {
        case TransferModel.Upload:
            imgSource = "image://theme/icon-s-cloud-upload"
            break;
        case TransferModel.Download:
            imgSource = "image://theme/icon-s-cloud-download"
            break;
        case TransferModel.Sync:
            imgSource = "image://theme/icon-s-sync"
            break;
        default:
            console.log("TransfersPage::transferIcon: failed to get transfer type")
            return ""
        }
        if (highlight) {
            imgSource += "?" + Theme.highlightColor
        }
        return imgSource
    }

    function mimeTypeIcon(mimeType, highlight) {
        if (mimeType.length > 0 && mimeType.split("/")[0] === "image") {
            return "" // no icon for images as the preview is already shown
        } else {
            return Theme.iconForMimeType(mimeType) + (highlight ? "?" + Theme.highlightColor : "")
        }
    }

    // Delegate for a transfer entry in a list
    Component {
        id: transferDelegate

        ListItem {
            id: transferEntry

            property int transferStatus: status
            property url fileUrl: url
            property url thumbnailUrl: thumbnailIcon
            property url appIconUrl: applicationIcon
            property Item thumbnailItem

            menu: contextMenuComponent
            openMenuOnPressAndHold: false
            contentHeight: Math.max(thumbnail.height, fileNameLabel.y + fileNameLabel.height + Theme.paddingMedium)

            enabled: !clearingTransfers || status === TransferModel.TransferStarted
            opacity: enabled ? 1.0 : 0.0
            Behavior on opacity { FadeAnimator {}}

            // Load thumbs on demand and only once. Note that share thumbnail is used only for local images/thumbs
            onFileUrlChanged: if (thumbnailItem == null) thumbnailItem = shareThumbnail.createObject(thumbnail)
            onThumbnailUrlChanged: if (thumbnailItem == null) thumbnailItem = shareThumbnail.createObject(thumbnail)
            onAppIconUrlChanged: if (thumbnailItem == null) thumbnailItem = appThumbnail.createObject(thumbnail)

            // Close open context menu, if the status changes
            onTransferStatusChanged: closeMenu()

            // Component for local thumbnails. Used for Upload or 'finished' entries.
            Component {
                id: shareThumbnail
                Thumbnail {
                    anchors.fill: parent
                    sourceSize.width: width
                    sourceSize.height: height
                    opacity: mimeTypeImage.source == "" ? 1.0 : Theme.opacityOverlay
                    source: thumbnailUrl != "" ? thumbnailUrl : fileUrl
                    priority: (status == Thumbnail.Ready || status == Thumbnail.Error)
                              ? Thumbnail.NormalPriority
                              : ((transferEntry.y >= transferList.contentY && transferEntry.y < transferList.contentY + transferList.height)
                                 ? Thumbnail.NormalPriority
                                 : Thumbnail.LowPriority)
                }
            }

            // Component for application thumbnail. Only used by Sync or Download entry.
            Component {
                id: appThumbnail
                Item {
                    anchors.fill: parent
                    Image {
                        source: applicationIcon
                        asynchronous: true
                        anchors.centerIn: parent
                        sourceSize.width: Theme.itemSizeSmall
                        sourceSize.height: Theme.itemSizeSmall
                    }
                }
            }

            Item {
                id: thumbnail
                width: Theme.itemSizeLarge
                height: Theme.itemSizeLarge
                readonly property bool isNeeded: thumbnailItem == null || thumbnailItem.status === Thumbnail.Null || thumbnailItem.status === Thumbnail.Error

                // Placeholder for entries without thumbnails
                Rectangle {
                    anchors.fill: parent
                    visible: thumbnail.isNeeded
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                Image {
                    id: mimeTypeImage
                    anchors.centerIn: parent
                    source: thumbnail.isNeeded ? mimeTypeIcon(mimeType, transferEntry.highlighted) : ""
                    asynchronous: true
                    z: 1    // place above the image thumbnail
                }
            }

            Image {
                id: transferTypeIcon
                source: transferIcon(transferType, transferEntry.highlighted)
                asynchronous: true
                anchors {
                    top: thumbnail.top
                    topMargin: Theme.paddingMedium
                    left: thumbnail.right
                    leftMargin: Theme.paddingLarge
                }
            }

            Label {
                text: statusText(transferType, status, fileSize, new Date(timestamp))
                font.pixelSize: Theme.fontSizeSmall
                color: status == TransferModel.TransferInterrupted
                       ? Theme.highlightColor
                       : (transferEntry.highlighted ? Theme.highlightColor : Theme.primaryColor)
                truncationMode: TruncationMode.Fade
                anchors {
                    verticalCenter: transferTypeIcon.verticalCenter
                    left: transferTypeIcon.right
                    leftMargin: Theme.paddingMedium
                    right: serviceTypeImage.left
                    rightMargin: Theme.paddingMedium
                }
            }

            ProgressBar {
                id: transferProgressBar
                anchors {
                    left: transferTypeIcon.left
                    right: parent.right
                    top: transferTypeIcon.bottom
                }
                leftMargin: 0
                rightMargin: Theme.horizontalPageMargin
                height: visible ? implicitHeight : Theme.paddingMedium
                value: visible ? progress : 0
                visible: status === TransferModel.TransferStarted
                indeterminate: progress < 0 || 1 < progress
                clip: true
                highlighted: transferEntry.highlighted

                Behavior on height { NumberAnimation {} }
            }

            Label {
                id: fileNameLabel
                text: resourceName
                wrapMode: Text.Wrap
                height: text.length ? implicitHeight : 0
                font.pixelSize: Theme.fontSizeExtraSmall
                color: transferEntry.highlighted || menuOpen ? Theme.secondaryHighlightColor : Theme.secondaryColor
                anchors {
                    left: thumbnail.right
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    top: transferProgressBar.bottom
                }
            }

            Image {
                id: serviceTypeImage
                source: serviceIcon
                width: Theme.iconSizeSmall
                height: width
                anchors {
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: transferTypeIcon.verticalCenter
                }
            }

            onPressAndHold: {
                if (down) {
                    openTransferContextMenu()
                }
            }

            onClicked: {
                // Properly finished transfers with local filename should open that file
                if (status === TransferModel.TransferFinished) {
                    var path = url
                    if (path.length > 0 && path[0] == '/') {
                        path = 'file://' + path
                    }

                    // Only open the URL externally if it's not a http(s) URL
                    if (path.substr(0, 7) != 'http://' && path.substr(0, 8) != 'https://') {
                        Qt.openUrlExternally(path)
                    }

                    return
                }

                openTransferContextMenu()
            }

            function openTransferContextMenu() {
                // There must be something enabled in order to show context menu
                var canRemove = status != TransferModel.TransferStarted
                var canCancel = model.cancelEnabled && status == TransferModel.TransferStarted
                var canRestart = model.restartEnabled
                        && (status == TransferModel.TransferInterrupted || status == TransferModel.TransferCanceled)
                if (canRemove || canCancel || canRestart) {
                    openMenu({"transferId": transferId,
                              "removeEnabled": canRemove,
                              "cancelEnabled": canCancel,
                              "restartEnabled": canRestart})
                }
            }


            // Context menu for actions such as cancel and restart
            Component {
                id: contextMenuComponent

                ContextMenu {
                    id: contextMenu
                    property int transferId
                    property bool removeEnabled
                    property bool cancelEnabled
                    property bool restartEnabled

                    MenuItem {
                        visible: cancelEnabled || restartEnabled
                        text: {
                            if (cancelEnabled) {
                                //% "Stop"
                                return qsTrId("transferui-la_stop-transfer")
                            } else if (restartEnabled) {
                                //% "Restart"
                                return qsTrId("transferui-la_restart-transfer")
                            }
                            return ""
                        }

                        onClicked: {
                            if (cancelEnabled) {
                                transferInterface.cbCancelTransfer(transferId)
                            } else if (restartEnabled) {
                                transferInterface.cbRestartTransfer(transferId)
                            }
                        }
                    }

                    MenuItem {
                        visible: removeEnabled
                        //% "Remove from history"
                        text: qsTrId("transferui-remove-from-history")
                        onClicked: {
                            var id = transferId
                            var transfer = transferInterface
                            //% "Removed"
                            transferEntry.remorseAction(qsTrId("transferui-remorse_removed"),
                                                        function() { transfer.clearTransfer(id) })
                        }
                    }
                }
            }
        }
    }

    // Interface for e.g. canceling a transfer
    SailfishTransferInterface {
        id: transferInterface
    }

    TransferModel {
        id: transferModel
        onCountChanged: if (count === 0) clearingTransfers = false
    }

    // Actual list which displays transfers
    SilicaListView {
        id: transferList

        header: PageHeader {
            //% "Transfers"
            title: qsTrId("transferui-he_transfers")
        }

        VerticalScrollDecorator {}

        PullDownMenu {
            bottomMargin: 0
            visible: transferModel.count > 0
            MenuItem {
                //% "Clear history"
                text: qsTrId("transferui-me_clear-history")
                onClicked: {
                    var remorse = Remorse.popupAction(
                                transfersPage,
                                //% "Cleared transfers"
                                qsTrId("transferui-la-cleared_transfers"),
                                function() {
                                    transferModel.clearTransfers()
                                })
                    clearingTransfers = true
                    remorse.canceled.connect(function() { clearingTransfers = false })
                }
            }
        }

        ViewPlaceholder {
            enabled: clearingTransfers || transferModel.count === 0 && transferModel.status == TransferModel.Finished
            //% "No Transfers"
            text: qsTrId("transferui-la-no_transfers")
        }

        anchors.fill: parent
        model: transferModel
        delegate: transferDelegate
        cacheBuffer: transferList.height
    }
}
