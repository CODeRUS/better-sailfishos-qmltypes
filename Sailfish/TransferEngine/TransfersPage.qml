import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0
import org.nemomobile.thumbnailer 1.0
import org.nemomobile.notifications 1.0
import org.nemomobile.transferengine 1.0

Page {
    id: transfersPage

    property Item _remorsePopup
    property date _today: new Date()

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

    // For some reason date object can't hand ISO8601 standard.
    // This function makes it compatible
    function dateFromISO8601(isostr) {
        var parts = isostr.match(/\d+/g);
        return new Date(parts[0], parts[1] - 1, parts[2], parts[3], parts[4], parts[5]);
    }

    function transferIcon(transferType) {
        // TODO: How we figure out if upload/download is from device2device e.g. BT.
        switch (transferType) {
        case TransferModel.Upload:
            return "image://theme/icon-s-cloud-upload"
        case TransferModel.Download:
            return "image://theme/icon-s-cloud-download"
        case TransferModel.Sync:
            return "image://theme/icon-s-sync"
        default:
            console.log("TransfersPage::transferIcon: failed to get transfer type")
            return ""
        }
    }

    function mimeTypeIcon(mimeType) {
        if (mimeType.length === 0)
            return ""
        var type = mimeType.split("/");

        // Handle basic media types
        if (type[0] === "image") {
            return ""   // no mime type icon for images
        } else if (type[0] === "video") {
            return "image://theme/icon-m-video"
        } else if (type[0] === "audio") {
            return "image://theme/icon-m-sound"
        }
        // Next doc types
        // TODO: CHECK the rest of document types
        if (type[1].indexOf("excel")   ||
            type[1].indexOf("pdf")     ||
            type[1].indexOf("word")    ||
            type[1].indexOf("powerpoint")) {
            return "image://theme/icon-m-document"
        }
        // Handle contacts
        if (type[1].indexOf("vcard")) {
            return "image://theme/icon-m-people"
        }
        return "image://theme/icon-m-other"
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
            showMenuOnPressAndHold: false

            // Adjust height if file name is very long
            contentHeight: Math.max(thumbnail.height,
                                    transferTypeIcon.height
                                    + transferProgressBar.height + fileNameLabel.height
                                    + Theme.paddingMedium*2)    // padding above and below status+progress+filename details

            // Load thumbs on demand and only once. Note that share thumbnail is used only for local images/thumbs
            onFileUrlChanged: if (thumbnailItem == null) thumbnailItem = shareThumbnail.createObject(thumbnail)
            onThumbnailUrlChanged: if (thumbnailItem == null) thumbnailItem = shareThumbnail.createObject(thumbnail)
            onAppIconUrlChanged: if (thumbnailItem == null) thumbnailItem = appThumbnail.createObject(thumbnail)

            // Close open context menu, if the status changes
            onTransferStatusChanged: hideMenu()

            // Component for local thumbnails. Used for Upload or 'finished' entries.
            Component {
                id: shareThumbnail
                Thumbnail {
                    anchors.fill: parent
                    sourceSize.width: width
                    sourceSize.height: height
                    opacity: mimeTypeImage.source == "" ? 1.0 : 0.8
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

                // Placeholder for entries without thumbnails
                Rectangle {
                    anchors.fill: parent
                    visible: thumbnailItem == null || thumbnailItem.status === Thumbnail.Null || thumbnailItem.status === Thumbnail.Error
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                Image {
                    id: mimeTypeImage
                    anchors.centerIn: parent
                    source: mimeTypeIcon(mimeType)
                    asynchronous: true
                    z: 1    // place above the image thumbnail
                }
            }

            Image {
                id: transferTypeIcon
                source: transferIcon(transferType)
                asynchronous: true
                anchors {
                    top: thumbnail.top
                    topMargin: Theme.paddingMedium
                    left: thumbnail.right
                    leftMargin: Theme.paddingLarge
                }
            }

            Label {
                text: statusText(transferType, status, fileSize, dateFromISO8601(timestamp))
                font.pixelSize: Theme.fontSizeSmall
                color: status == TransferModel.TransferInterrupted
                       ? Theme.highlightColor
                       : (transferEntry.highlighted || menuOpen ? Theme.highlightColor : Theme.primaryColor)
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
                rightMargin: Theme.paddingLarge
                height: visible ? Theme.itemSizeSmall : Theme.paddingMedium
                value: visible ? progress : 0
                visible: status === TransferModel.TransferStarted
                indeterminate: progress < 0 || 1 < progress
                clip: true

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
                    rightMargin: Theme.paddingLarge
                    top: transferProgressBar.bottom
                }
            }

            Image {
                id: serviceTypeImage
                source: serviceIcon
                width: Theme.itemSizeSmall / 2
                height: width
                anchors {
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                    verticalCenter: transferTypeIcon.verticalCenter
                }
            }


            onClicked: {
                // Properly finished transfers with local filename should open that file
                if (status === TransferModel.TransferFinished) {
                    var path = url;
                    if (path.length > 0 && path[0] == '/') {
                        path = 'file://' + path;
                    }

                    // Only open the URL externally if it's not a http(s) URL
                    if (path.substr(0, 7) != 'http://' && path.substr(0, 8) != 'https://') {
                        var ok = ContentAction.trigger(path)
                        if (!ok) {
                            switch (ContentAction.error) {
                            case ContentAction.FileTypeNotSupported:
                                //: Notification text shown when file not supported error occured.
                                //% "Oops, file type not supported"
                                errorNotification.show(path,  qsTrId("jolla-transferui-no-error-file-not-supported"))
                                break
                            case ContentAction.FileDoesNotExist:
                                //: Notification text shown when file doesn't exist error occured.
                                //% "Oops, file doesn't exist"
                                errorNotification.show(path,  qsTrId("jolla-transferui-no-error-file-does-not-exist"))
                                break
                            case ContentAction.InvalidUrl:
                                //: Notification text shown when file invalid url error occured.
                                //% "Oops, invalid file url"
                                errorNotification.show(path,  qsTrId("jolla-transferui-no-error-invalid-url"))
                                break
                            default:
                                console.log("Unknown content action error!")
                            }
                        }
                    }
                    return;
                }

                // There must be cancel or restart enabled in order to show context menu
                if (cancelEnabled || restartEnabled) {
                    showMenu({"transferId": transferId,
                              "status": status,
                              "cancelEnabled": cancelEnabled,
                              "restartEnabled": restartEnabled})
                }
            }
        }
    }

    // Interface for e.g. canceling a transfer
    SailfishTransferInterface {
        id: transferInterface
    }

    // Actual list which displays transfers
    SilicaListView {
        id: transferList
        property Item contextMenu

        header: PageHeader {
            //% "Transfers"
            title: qsTrId("transferui-he_transfers")
        }

        VerticalScrollDecorator {}

        PullDownMenu {
            bottomMargin: 0
            visible: transferModel.count > 0
            MenuItem {
                //% "Clear all"
                text: qsTrId("transferui-me_clear-all")
                onClicked: {
                    if (_remorsePopup === null) {
                        _remorsePopup = remorsePopupComponent.createObject(transfersPage)
                    }

                    //: Clearing transfers in 5 seconds
                    //% "Clearing transfers"
                    _remorsePopup.execute(qsTrId("transferui-me-clear-transfers"),
                                              function() {
                                                  transferModel.clearTransfers()
                                              }
                                          )
                }

                Component {
                    id: remorsePopupComponent
                    RemorsePopup {}
                }
            }
        }

        ViewPlaceholder {
            enabled: transferModel.count === 0
            //% "No Transfers"
            text: qsTrId("transferui-la-no_transfers")
        }

        anchors.fill: parent
        model: transferModel
        delegate: transferDelegate
        cacheBuffer: transferList.height
    }

    Notification {
        id: errorNotification

        category: "x-jolla.transferui.error"

        function show(path, summary)
        {
            var startIndex = path.lastIndexOf("/")
            var fileName = path
            if (startIndex >= 0 &&  startIndex + 1 < path.length - 1 )
                fileName = path.substr(startIndex + 1, path.length - 1)

            previewSummary = summary
            previewBody = fileName
            publish()
        }
    }

    // Context menu for actions such as cancel and restart
    Component {
        id: contextMenuComponent

        ContextMenu {
            property int transferId
            property int status
            property bool cancelEnabled
            property bool restartEnabled

            function setText()
            {
                switch (status) {
                case TransferModel.TransferStarted:
                    //% "Stop"
                    return qsTrId("transferui-la_stop-transfer")
                case TransferModel.TransferCanceled:
                case TransferModel.TransferInterrupted:
                    //% "Restart"
                    return qsTrId("transferui-la_restart-transfer")
                case TransferModel.TransferFinished:
                default:
                    return ""
                }

            }

            function menuAction()
            {
                switch (status) {
                case TransferModel.TransferStarted:
                    transferInterface.cbCancelTransfer(transferId)
                    break;
                case TransferModel.TransferCanceled:
                case TransferModel.TransferInterrupted:
                    transferInterface.cbRestartTransfer(transferId)
                    break;
                case TransferModel.TransferFinished:
                    console.log("Not implemented")
                    break
                }
            }

            MenuItem {
                text: setText()
                onClicked: menuAction()
            }
        }
    }
}