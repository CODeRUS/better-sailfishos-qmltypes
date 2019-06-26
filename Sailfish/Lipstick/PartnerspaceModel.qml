import QtQuick 2.0
import org.nemomobile.lipstick 0.1
import org.nemomobile.configuration 1.0
import Nemo.DBus 2.0

LauncherWatcherModel {
    id: model

    readonly property alias maximumApplicationCount: partnerspaceSettings.maximumApplicationCount
    readonly property alias categories: partnerspaceSettings.categories
    readonly property alias applications: model.filePaths
    property bool includeAmbience

    filePaths: _filePaths()

    function _filePaths() {
        var filePaths = []
        var applications = partnerspaceSettings.applications
        for (var i = 0; i < applications.length; ++i) {
            filePaths.push(applications[i])
        }
        if (includeAmbience) {
            filePaths.push(partnerspaceSettings.ambience)
        }
        return filePaths
    }

    function setApplication(index, path) {
        // Manually copy the applications list as the array object
        // returned by filePaths doesn't allow modifications.
        var applications = []
        var existing = filePaths
        for (var i = 0; i < existing.length; ++i) {
            applications.push(existing[i])
        }

        if (index === -1) {
            applications.unshift(path)
        } else if (path !== "") {
            applications[index] = path
        } else {
            applications.splice(index, 1)
        }

        filePaths = applications
    }

    function save() {
        partnerspaceSettings.applications = filePaths
        partnerspaceSettings.sync()

        reset()
    }

    function reset() {
        filePaths = Qt.binding(_filePaths)
    }

    property list<QtObject> _resources: [
        ConfigurationGroup {
            id: partnerspaceSettings

            path: "/desktop/lipstick-jolla-home/partnerspace"

            property int maximumApplicationCount: 3

            property variant categories: ["X-SailfishPartnerSpace"]
            property string ambience
            property variant applications: []
        }
    ]
}
