import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel {
    property string filter

    query: "/xml/searchresults/loc"
    source: filter.length > 0 ? "http://feed-jll.foreca.com/jolla-jan14fi/search.php?q=" + filter.toLowerCase() + "&lang=" + Qt.locale().name.split("_")[0] : ""

    // For example <loc id="102643743" name="London" adm1="England" country="United Kingdom" tz="Europe/London" lon="-0.125532746" lat="51.508415222">
    XmlRole {
        name: "locationId"
        query: "@id/string()"
    }
    XmlRole {
        name: "city"
        query: "@name/string()"
    }
    XmlRole {
        name: "state"
        query: "@adm1/string()"
    }
    XmlRole {
        name: "country"
        query: "@country/string()"
    }
}
