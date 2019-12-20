import QtQuick 2.6
import Sailfish.Silica 1.0

Label {
    property var textBaseItem
    property real defaultOpacity: {
         if (!textBaseItem) {
             return 1.0
         }
         var baseOpacity = textBaseItem.hideLabelOnEmptyField ? 1.0 - textBaseItem._placeholderTextLabel.opacity
                                                              : 1.0
         return (textBaseItem.errorHighlight || textBaseItem.highlighted ? 1.0 : Theme.opacityHigh) * baseOpacity
    }

    text: !!textBaseItem ? textBaseItem.label : ""
    color: !!textBaseItem ? textBaseItem.color : palette.highlightColor
    horizontalAlignment: !!textBaseItem ? textBaseItem._placeholderTextLabel.horizontalAlignment : Text.AlignLeft
    opacity: defaultOpacity
    truncationMode: TruncationMode.Fade
    font.pixelSize: Theme.fontSizeSmall
}
