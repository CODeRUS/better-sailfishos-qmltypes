import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Email 0.1

Page {
    id: root

    property EmailMessage email
    property Item composerItem
    property int undownloadedAttachmentsCount
    property bool downloadInProgress

    onStatusChanged: {
        if (status === PageStatus.Deactivating && downloadInProgress) {
            email.cancelMessageDownload()
            busyIndicator.running = false
        } else if (status === PageStatus.Deactivating && !composerItem.discardUndownloadedAttachments) {
            composerItem.removeUndownloadedAttachments()
            composerItem.discardUndownloadedAttachments = true
        }
    }

    Column {
        x: Theme.horizontalPageMargin
        anchors.top: parent.top
        anchors.topMargin: Theme.itemSizeLarge // Page header size
        width: parent.width - x*2
        spacing: Theme.paddingLarge
        visible: !busyIndicator.running

        Label {
            width: parent.width
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.highlightColor
            //: When singular "Download attachment?" when plural "Download attachments?"
            //% "Download attachment?"
            text: qsTrId("jolla-email-la-download-attachments-header", undownloadedAttachmentsCount)
        }

        Label {
            id: informationLabel
            width: parent.width
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.rgba(Theme.highlightColor, 0.9)
            //: When singular "The attachment you are forwarding has not been downloaded yet",
            //: plural "Some of the attachments you are forwarding have not been downloaded yet"
            //% "The attachment you are forwarding has not been downloaded yet."
            text: qsTrId("jolla-email-la-forward-attachments-info", undownloadedAttachmentsCount)
        }
    }

    ButtonLayout {
        anchors {
            bottom: parent.bottom
            bottomMargin: Theme.itemSizeMedium
        }
        preferredWidth: Theme.buttonWidthMedium

        Button {
            id: downloadAttachButton
            visible: !busyIndicator.running
            //: Download attachments button
            //% "Download"
            text: qsTrId("jolla-email-la-download_attachments_forward")
            onClicked: {
                busyIndicator.running = true
                downloadInProgress = true
                email.downloadMessage()
            }
        }
        Button {
            visible: !busyIndicator.running
            //: Discard not downloaded attachments button
            //% "Discard"
            text: qsTrId("jolla-email-la-discard_not_downloaded_attachments")
            onClicked: {
                composerItem.removeUndownloadedAttachments()
                composerItem.discardUndownloadedAttachments = true
                pageStack.pop()
            }
        }
    }

    Column {
        anchors.centerIn: parent
        x: Theme.horizontalPageMargin
        width: parent.width - x*2
        spacing: Theme.paddingLarge
        visible: busyIndicator.running

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            color: Theme.secondaryHighlightColor
            //: When singular "Downloading attachment", when plural "Downloading attachments
            //% "Downloading attachment..."
            text: qsTrId("jolla-email-la-downloading-attachments", undownloadedAttachmentsCount)
        }

        BusyIndicator {
            id: busyIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            size: BusyIndicatorSize.Large
            running: false
        }
    }

    Connections {
        target: email
        onMessageDownloaded: {
            downloadInProgress = false
            composerItem.setOriginalMessageAttachments()
            pageStack.pop()
        }

        onMessageDownloadFailed: {
            downloadInProgress = false
            //: When singular "The attachment could not be downloaded, please check your internet connection.",
            //: when plural "Some attachments could not be downloaded, please check your internet connection."
            //% "The attachment could not be downloaded, please check your internet connection."
            informationLabel.text = qsTrId("jolla-email-la-attachments-download-failed-info", undownloadedAttachmentsCount)
            //: Try again button
            //% "Try again"
            downloadAttachButton.text = qsTrId("jolla-email-la-download-attachments_try_again")
            busyIndicator.running = false
        }
    }
}
