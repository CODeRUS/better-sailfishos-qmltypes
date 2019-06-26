import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

ExpandingMenu {
    model: [ "image", "video" ]
    delegate: ExpandingMenuItem {
        settings: Settings.global
        property: "captureMode"
        value: modelData
        icon: Settings.captureModeIcon(modelData)
    }
}
