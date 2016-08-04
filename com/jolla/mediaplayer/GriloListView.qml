// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.mediaplayer 1.0

MediaPlayerListView {
    property string query

    Binding {
        target: model
        property: "query"
        value: query
    }
}
