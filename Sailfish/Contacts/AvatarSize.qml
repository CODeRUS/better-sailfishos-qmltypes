pragma Singleton
import QtQuick 2.6
import Sailfish.Silica 1.0

Item {
    // Avatar area fits minimum of 2 name lines + 2 company info lines + padding.
    readonly property int minimumSize: Theme.paddingMedium + (nameFont.height * 2)
                                       + Theme.paddingSmall + (companyInfoFont.height * 2)
                                       + Theme.paddingMedium

    readonly property int thumbnailSize: {
        if (_initialized) {
            var portraitColumns = Math.floor(Screen.width / minimumSize)
            return (Screen.width - symbolScrollBarWidth) / portraitColumns
        } else {
            return 0
        }
    }
    property bool _initialized

    // Keep in sync with SymbolScrollBar.implicitWidth
    property int symbolScrollBarWidth: (Theme.iconSizeSmall * 1.25 + 2 * Theme.paddingMedium)

    Component.onCompleted: _initialized = true

    FontMetrics {
        id: nameFont
        font.pixelSize: Theme.fontSizeMedium
    }

    FontMetrics {
        id: companyInfoFont
        font.pixelSize: Theme.fontSizeTiny
    }
}
