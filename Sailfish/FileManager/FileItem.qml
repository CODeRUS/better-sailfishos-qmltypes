import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    property bool compressed

    width: ListView.view.width
    contentHeight: Theme.itemSizeMedium
    Row {
        anchors.fill: parent
        spacing: Theme.paddingLarge
        Rectangle {
            width: height
            height: parent.height
            gradient: Gradient {
                // Abusing gradient for inactive mimeTypes
                GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
                GradientStop { position: 1.0; color: "transparent" }
            }

            Image {
                anchors.centerIn: parent
                source: {
                    var iconSource = model.isDir ? "image://theme/icon-m-file-folder"
                                                 : Theme.iconForMimeType(model.mimeType)
                    return iconSource + (highlighted ? "?" + Theme.highlightColor : "")
                }
            }

            Image {
                anchors {
                    top: parent.top
                    right: parent.right
                }
                visible: compressed

                source: {
                    var iconSource = "image://theme/icon-m-file-compressed"
                    return iconSource + (highlighted ? "?" + Theme.highlightColor : "")
                }
            }



        }
        Column {
            width: parent.width - parent.height - parent.spacing - Theme.horizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
            Label {
                text: model.fileName
                width: parent.width
                truncationMode: TruncationMode.Fade
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            Label {
                property string dateString: Format.formatDate(model.modified || model.created, Formatter.DateLong)
                text: model.isDir ? dateString
                                    //: Shows size and modification/created date, e.g. "15.5MB, 02/03/2016"
                                    //% "%1, %2"
                                  : qsTrId("filemanager-la-file_details").arg(Format.formatFileSize(model.size)).arg(dateString)
                width: parent.width
                truncationMode: TruncationMode.Fade
                font.pixelSize: Theme.fontSizeExtraSmall
                color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            }
        }
    }
}
