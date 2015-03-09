import QtQuick 2.0
import Sailfish.Silica 1.0

Label {
    wrapMode: Text.WordWrap
    font {
        family: Theme.fontFamilyHeading
        pixelSize: Theme.fontSizeExtraLarge
    }
    color: Theme.highlightColor

    //% "Sailfish OS Terms of Use"
    text: qsTrId("startupwizard-he-sailfish_terms")
}
