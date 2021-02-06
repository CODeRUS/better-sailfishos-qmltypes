import QtQuick 2.0
import Sailfish.Weather 1.0

ListModel {
    id: root

    property string filter
    property alias status: model.status

    onFilterChanged: if (filter.length === 0) clear()

    function reload() {
        model.reload()
    }

    readonly property WeatherRequest model: WeatherRequest {
        id: model

        property string language: {
            var locale = Qt.locale().name
            if (locale === "zh_CN" || locale === "zh_TW") {
                return locale
            } else {
                return locale.split("_")[0]
            }
        }

        source: filter.length > 0 ? "https://pfa.foreca.com/api/v1/location/search/" + filter.toLowerCase() + "&lang=" + language : ""
        onRequestFinished: {
            var locations = result["locations"]
            if (result.length === 0 || locations === undefined) {
                status = Weather.Error
            } else {
                while (root.count > locations.length) {
                    root.remove(locations.length)
                }
                for (var i = 0; i < locations.length; i++) {
                    if (i < root.count) {
                        root.set(i, locations[i])
                    } else {
                        root.append(locations[i])
                    }
                }
            }
        }

        onStatusChanged: {
            if (status === Weather.Error) {
                root.clear()
                console.log("LocationsModel - location search failed with query string", filter)
            }
        }
    }
}
