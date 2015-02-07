import QtQuick 2.0
import Sailfish.Silica 1.0

MainPage {
    property alias tutorialTheme: tutorialThemeId
    property bool allowSystemGesturesBetweenLessons

    property bool _tutorialStarted

    onStatusChanged: {
        if (status === PageStatus.Active) {
            // Don't override window and application window properties
            // before the tutorial really starts.
            _tutorialStarted = true
        }
    }

    Binding {
       target: __quickWindow
       property: "color"
       value: "black"
       when: _tutorialStarted
    }

    Binding {
       target: __silica_applicationwindow_instance
       property: "_backgroundVisible"
       value: false
       when: _tutorialStarted
    }

    Binding {
       target: __silica_applicationwindow_instance
       property: "dimmedRegionColor"
       value: tutorialThemeId.highlightDimmerColor
       when: _tutorialStarted
    }

    QtObject {
        id: tutorialThemeId
        property color highlightColor: "#88f5e0"
        property color secondaryHighlightColor: "#b588f5e0"
        property color primaryColor: "#ffffffff"
        property color secondaryColor: "#b0ffffff"
        property color highlightBackgroundColor: "#00e6b9"
        property color highlightDimmerColor: "#003329"
    }
}
