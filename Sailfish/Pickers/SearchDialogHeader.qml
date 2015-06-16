import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

FocusScope {
    property alias placeholderText: searchField.placeholderText
    property alias dialog: header.dialog
    property int contentType: ContentType.InvalidType
    property alias searchFieldLeftMargin: searchField.textLeftMargin
    property QtObject model
    readonly property bool active: searchField.text.length > 0

    property alias _glassOnly: header._glassOnly

    implicitHeight: col.height

    Column {
        id: col
        width: parent.width
        DialogHeader {
            id: header

            spacing: 0
            acceptText: {
                if (model.singleSelectionMode) {
                    return dialog.acceptText.length ? dialog.acceptText : defaultAcceptText
                } else {
                    var selectedCount = model.selectedModel ? model.selectedModel.selectedCount(contentType) : 0
                    //: Multi content picker number of selected content items
                    //% "%n selected"
                    return selectedCount > 0 ? qsTrId("components_pickers-he-multiselect_accept", selectedCount) :
                                               (dialog.acceptText.length ? dialog.acceptText : defaultAcceptText)
                }
            }
        }

        SearchField {
            id: searchField
            width: parent.width
        }

        Binding {
            target: model
            property: "filter"
            value: searchField.text.toLowerCase().trim()
        }
    }
}
