import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: webViewPage

    property var activeWebView

    property int __sailfish_webviewpage
    default property alias _contentChildren: content.data

    orientationTransitions: orientationFader.orientationTransition

    Item {
        id: content
        anchors.centerIn: parent
        width: webViewPage.width
        height: webViewPage.height
    }

    OrientationFader {
        id: orientationFader

        visible: !!activeWebView
        x: activeWebView ? activeWebView.x : 0
        y: activeWebView ? activeWebView.y : 0
        width: activeWebView ? activeWebView.width : 0
        height: activeWebView ? activeWebView.height : 0

        page: webViewPage
        fadeTarget: content
        color: activeWebView ? activeWebView.bgcolor : "white"

        onContentOrientationChanged: {
            // Update content size manually while virtual keyboard is open.
            orientationFader.waitForWebContentOrientationChanged = true
            if (activeWebView && activeWebView.virtualKeyboardMargin > 0) {
                activeWebView.updateContentSize(Qt.size(activeWebView.width,
                                                        (activeWebView.virtualKeyboardMargin + activeWebView.height)))
            }
        }
    }

    Connections {
        target: activeWebView
        ignoreUnknownSignals: true
        onContentOrientationChanged: orientationFader.waitForWebContentOrientationChanged = false
    }

    states: [
        State {
            name: "webViewActive"
            when: activeWebView != null && activeWebView != undefined && activeWebView.visible && activeWebView.active
            PropertyChanges {
                target: pageStack
                _noGrabbing: activeWebView.moving || activeWebView.pinching || activeWebView.dragging
            }
            PropertyChanges {
                target: webViewPage
                backNavigation: activeWebView.atXBeginning && !activeWebView.pinching
                forwardNavigation: webViewPage._belowTop && activeWebView.atXEnd && !activeWebView.pinching
            }
        }
    ]
}
