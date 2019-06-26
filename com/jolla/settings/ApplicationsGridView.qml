import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import com.jolla.settings 1.0

// provides the grid layout. The delegate must be provided, i.e. a LauncherGridItem
IconGridViewBase {
    id: gridView

    height: parent.height
    // assuming pushed page doesn't force different orientation
    pageHeight: pageStack.currentPage.isPortrait ? Screen.height : Screen.width

    VerticalScrollDecorator {
        anchors.rightMargin: -(gridView.parent.width - gridView.width)/2
    }

    model: ApplicationsModel
}
