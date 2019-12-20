pragma Singleton

import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.FileManager 1.0
import org.nemomobile.contentaction 1.0

Item {
    id: root

    property PageStack pageStack

    /*!
    \internal

    Implementation detail for file manager
    */
    property FileManagerNotification errorNotification

    // Call before start to use
    function init(pageStack) {
        root.pageStack = pageStack
    }

    function openDirectory(properties) {
        if (!properties.hasOwnProperty("errorNotification")) {
            createErrorNotification()
            properties["errorNotification"] = root.errorNotification
        }

        return pageStack.animatorPush(Qt.resolvedUrl("DirectoryPage.qml"), properties)
    }

    function openArchive(file, path, baseExtractionDirectory, stackAction) {
        createErrorNotification()
        stackAction = stackAction || PageStackAction.Animated

        var properties = {
            archiveFile: file,
            path: path || "/",
            errorNotification: errorNotification
        }

        if (baseExtractionDirectory) {
            properties["baseExtractionDirectory"] = baseExtractionDirectory
        }

        return pageStack.animatorPush(Qt.resolvedUrl("ArchivePage.qml"), properties, stackAction)
    }

    function createErrorNotification() {
        if (!errorNotification) {
            errorNotification = errorNotificationComponent.createObject(root)
        }
    }

    function pathToUrl(path) {
        if (path.indexOf("file://") == 0) {
            console.warn("pathToUrl() argument already url:", path)
            return path
        }

        return "file://" + path.split("/").map(encodeURIComponent).join("/")
    }

    Component {
        id: errorNotificationComponent

        FileManagerNotification {}
    }
}
