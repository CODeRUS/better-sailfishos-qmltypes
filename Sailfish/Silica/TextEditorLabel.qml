import QtQuick 2.6
import Sailfish.Silica 1.0

Label {
    property var editor

    Component.onCompleted: if (!editor) console.warn("TextEditorLabel requires editor to be set to TextField or TextArea")

    text: editor ? editor.label : ""
    font.pixelSize: Theme.fontSizeSmall
    truncationMode: TruncationMode.Fade
    color: editor.errorHighlight ? palette.errorColor
                                 : highlighted ? palette.secondaryHighlightColor
                                               : palette.secondaryColor

    horizontalAlignment: editor && editor.explicitHorizontalAlignment ? editor.horizontalAlignment : undefined
    opacity: editor && (editor._isEmpty && editor.hideLabelOnEmptyField) ? 0.0 : 1.0
    Behavior on opacity { FadeAnimation {}}
}
