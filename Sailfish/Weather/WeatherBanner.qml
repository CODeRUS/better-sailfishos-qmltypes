import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

BackgroundItem {

    id: weatherData
    property bool autoRefresh: false
    property bool active: true 
    property QtObject meecastData
    property bool expanded

    onClicked: {expanded = !expanded; weatherData.refresh()}
    onPressAndHold: { weatherData.meecastData.startMeeCast()}

    Component.onCompleted: {
        meecastData = Qt.createQmlObject('import QtQuick 2.0; import org.meecast.data 1.0 as Meecast; Meecast.Data {}', weatherData)
    }

    function refresh(){

        icon.source = weatherData.meecastData.forecastdata["item1_icon"]
        stationname.text = weatherData.meecastData.nameString 
        description.text = weatherData.meecastData.forecastdata["item1_description"] ? weatherData.meecastData.forecastdata["item1_description"] : "MeeCast"
        if (weatherData.meecastData.forecastdata["item1_temperature"] && weatherData.meecastData.forecastdata["item1_temperature"] != "N/A"){
            temperature.text = weatherData.meecastData.forecastdata["item1_temperature"] + '°' + weatherData.meecastData.forecastdata["temperatureunit"]
        }else{
             temperature.text = weatherData.meecastData.forecastdata["item1_temperature_low"] +  '°' + weatherData.meecastData.forecastdata["temperatureunit"] + "/"+  weatherData.meecastData.forecastdata["item1_temperature_high"] + '°' + weatherData.meecastData.forecastdata["temperatureunit"]
        }
        if (expanded){
            last_update.text = "Last update: " + weatherData.meecastData.forecastdata["last_update"]
            if ( weatherData.meecastData.forecastdata["item2_temperature_high"] == "N/A" || weatherData.meecastData.forecastdata["item2_temperature_low"] == "N/A" ){   
                temperature_2.text = weatherData.meecastData.forecastdata["item2_temperature"] + '°'
            }else{
                if (weatherData.meecastData.forecastdata["item2_temperature_low"] && weatherData.meecastData.forecastdata["item2_temperature_high"])
                    temperature_2.text = weatherData.meecastData.forecastdata["item2_temperature_low"]  + '°' + "\n"+  weatherData.meecastData.forecastdata["item2_temperature_high"]  + '°'     
                else{
                    temperature_2.text = "" 
                }
            }
            if ( weatherData.meecastData.forecastdata["item3_temperature_high"] == "N/A" || weatherData.meecastData.forecastdata["item3_temperature_low"] == "N/A" ){   
                temperature_3.text = weatherData.meecastData.forecastdata["item3_temperature"] + '°'
            }else{
                if (weatherData.meecastData.forecastdata["item3_temperature_low"] && weatherData.meecastData.forecastdata["item3_temperature_high"])
                    temperature_3.text = weatherData.meecastData.forecastdata["item3_temperature_low"]  + '°' + "\n"+  weatherData.meecastData.forecastdata["item3_temperature_high"]  + '°'     
                else{
                    temperature_3.text = "" 
                }
            }
            if ( weatherData.meecastData.forecastdata["item4_temperature_high"] == "N/A" || weatherData.meecastData.forecastdata["item4_temperature_low"] == "N/A" ){   
                temperature_4.text = weatherData.meecastData.forecastdata["item4_temperature"] + '°'
            }else{
                if (weatherData.meecastData.forecastdata["item4_temperature_low"] && weatherData.meecastData.forecastdata["item4_temperature_high"])
                    temperature_4.text = weatherData.meecastData.forecastdata["item4_temperature_low"]  + '°' + "\n"+  weatherData.meecastData.forecastdata["item4_temperature_high"]  + '°'     
                else{
                    temperature_4.text = "" 
                }
            }
            if ( weatherData.meecastData.forecastdata["item5_temperature_high"] == "N/A" || weatherData.meecastData.forecastdata["item5_temperature_low"] == "N/A" ){   
                temperature_5.text = weatherData.meecastData.forecastdata["item5_temperature"] + '°'
            }else{
                if (weatherData.meecastData.forecastdata["item5_temperature_low"] && weatherData.meecastData.forecastdata["item5_temperature_high"])
                    temperature_5.text = weatherData.meecastData.forecastdata["item5_temperature_low"]  + '°' + "\n"+  weatherData.meecastData.forecastdata["item5_temperature_high"]  + '°'     
                else{
                    temperature_5.text = "" 
                }
            }
            if ( weatherData.meecastData.forecastdata["item6_temperature_high"] == "N/A" || weatherData.meecastData.forecastdata["item6_temperature_low"] == "N/A" ){   
                temperature_6.text = weatherData.meecastData.forecastdata["item6_temperature"] + '°'
            }else{
                if (weatherData.meecastData.forecastdata["item6_temperature_low"] && weatherData.meecastData.forecastdata["item6_temperature_high"])
                    temperature_6.text = weatherData.meecastData.forecastdata["item6_temperature_low"]  + '°' + "\n"+  weatherData.meecastData.forecastdata["item6_temperature_high"]  + '°'     
                else{
                    temperature_6.text = "" 
                }
            }
            if ( weatherData.meecastData.forecastdata["item7_temperature_high"] == "N/A" || weatherData.meecastData.forecastdata["item7_temperature_low"] == "N/A" ){   
                temperature_7.text = weatherData.meecastData.forecastdata["item7_temperature"] + '°'
            }else{
                if (weatherData.meecastData.forecastdata["item7_temperature_low"] && weatherData.meecastData.forecastdata["item7_temperature_high"])
                    temperature_7.text = weatherData.meecastData.forecastdata["item7_temperature_low"]  + '°' + "\n"+  weatherData.meecastData.forecastdata["item7_temperature_high"]  + '°'     
                else{
                    temperature_7.text = "" 
                }
            }
            if ( weatherData.meecastData.forecastdata["item8_temperature_high"] == "N/A" || weatherData.meecastData.forecastdata["item8_temperature_low"] == "N/A" ){   
                temperature_8.text = weatherData.meecastData.forecastdata["item8_temperature"] + '°'
            }else{
                if (weatherData.meecastData.forecastdata["item8_temperature_low"] && weatherData.meecastData.forecastdata["item8_temperature_high"])
                    temperature_8.text = weatherData.meecastData.forecastdata["item8_temperature_low"]  + '°' + "\n"+  weatherData.meecastData.forecastdata["item8_temperature_high"]  + '°'     
                else{
                    temperature_8.text = "" 
                }
            }

            day_name_2.text = weatherData.meecastData.forecastdata["item2_short_day_name"]
            day_name_3.text = weatherData.meecastData.forecastdata["item3_short_day_name"]
            day_name_4.text = weatherData.meecastData.forecastdata["item4_short_day_name"]
            day_name_5.text = weatherData.meecastData.forecastdata["item5_short_day_name"]
            day_name_6.text = weatherData.meecastData.forecastdata["item6_short_day_name"]
            day_name_7.text = weatherData.meecastData.forecastdata["item7_short_day_name"]
            day_name_8.text = weatherData.meecastData.forecastdata["item8_short_day_name"]
            icon2.source = weatherData.meecastData.forecastdata["item2_icon"]
            icon3.source = weatherData.meecastData.forecastdata["item3_icon"]
            icon4.source = weatherData.meecastData.forecastdata["item4_icon"]
            icon5.source = weatherData.meecastData.forecastdata["item5_icon"]
            icon6.source = weatherData.meecastData.forecastdata["item6_icon"]
            icon7.source = weatherData.meecastData.forecastdata["item7_icon"]
            icon8.source = weatherData.meecastData.forecastdata["item8_icon"]
        }

    }
    function reload() {
        console.log("reload")
    }
    function save() {
    }

    visible: enabled
    enabled: enabled 
    height: enabled ? column.height : 0
    
    Column {
        id: column
        width: parent.width
        anchors {
            left: parent.left
        }
        Row {
            id: current_row
            spacing: Theme.paddingMedium
            anchors.horizontalCenter: parent.horizontalCenter
            height: Theme.itemSizeSmall
            anchors.left: parent.left
            anchors.leftMargin: isPortrait ? Theme.paddingSmall : Theme.paddingMedium + Theme.paddingSmall

            Image {
                id: icon
                height: parent.height 
                width: height
                source: weatherData.meecastData.forecastdata["item1_icon"]
            }
            Label {
                id: temperature
                text: {
                    if (weatherData.meecastData.forecastdata["item1_temperature"] && weatherData.meecastData.forecastdata["item1_temperature"] != "N/A"){
                        return weatherData.meecastData.forecastdata["item1_temperature"] + '°' 
                    }else{
                        if (weatherData.meecastData.forecastdata["item1_temperature_low"] && weatherData.meecastData.forecastdata["item1_temperature_high"])
                            return weatherData.meecastData.forecastdata["item1_temperature_low"] +  '°' + "/"+  weatherData.meecastData.forecastdata["item1_temperature_high"] + '°' 
                        else
                            return ""
                    }
                }
                y: isPortrait ? Theme.paddingLarge : Theme.paddingMedium
                anchors {
                    top: parent.top
                }
                font {
                    pixelSize: isPortrait ? Theme.fontSizeHuge : Theme.fontSizeExtraLarge
                    family: Theme.fontFamilyHeading
                }
            }

            Column {
                width:  parent.width - temperature.width - icon.width 
                Label {
                    id: stationname
                    width: parent.width
                    text: weatherData.meecastData.nameString ? weatherData.meecastData.nameString : "MeeCast"
                    //color: Theme.primaryColor 
                    color: Theme.highlightColor 
                    //horizontalAlignment: Text.AlignRight
                    horizontalAlignment: Text.AlignHCenter
                    font {
                        pixelSize: Theme.fontSizeLarge 
                        family: Theme.fontFamilyHeading
                    }
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    id: description 
                    width: parent.width
                    text: weatherData.meecastData.forecastdata["item1_description"] ? weatherData.meecastData.forecastdata["item1_description"] : "MeeCast"
                    horizontalAlignment: Text.AlignHCenter
                    font {
                        pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                        family: Theme.fontFamilyHeading
                    }
                    color: Theme.secondaryColor
                    truncationMode: TruncationMode.Fade
                }
            }
        }
        Row {
            id: forecasts_row
//            x: Theme.horizontalPageMargin-Theme.paddingLarge
//            width: parent.width - 2*x
            width: parent.width 
            height: 0
            opacity: 0.0
            spacing: Theme.paddingMedium*1.16
            states: State {
                name: "expanded"
                when: weatherData.expanded
                PropertyChanges {
                    target: forecasts_row
                    opacity: 1.0
                    height: 1.6*(Screen.sizeCategory >= Screen.Large ? Theme.itemSizeLarge : Theme.itemSizeSmall)
                }
            }

            Row {
                id: forecast2_row
                Column {
                    id: icon_day_column2
                    Label {
                        id: day_name_2 
                        anchors.bottom: icon_2.top 
                        anchors.bottomMargin: -Theme.paddingSmall
                        font.pixelSize: Theme.fontSizeSmall 
                        color: Theme.secondaryColor
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                        text: weatherData.meecastData.forecastdata["item2_short_day_name"]
                    }
                    Row{
                        Image {
                            id: icon2
                            height: Screen.sizeCategory >= Screen.Large ? Theme.itemSizeLarge : Theme.itemSizeSmall 
                            width: height
                            source: weatherData.meecastData.forecastdata["item2_icon"]
                        }
                        Label {
                            id: temperature_2 
                            font.pixelSize: Theme.fontSizeSmall
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: icon2.height
                            wrapMode: Text.Wrap
                            width: 1.6*Theme.fontSizeSmall
                            text: {
                                if ( weatherData.meecastData.forecastdata["item2_temperature_high"] == "N/A" || weatherData.meecastData.forecastdata["item2_temperature_low"] == "N/A" ){   
                                    return weatherData.meecastData.forecastdata["item2_temperature"] + '°'                        }else{
                                    if (weatherData.meecastData.forecastdata["item2_temperature_low"] && weatherData.meecastData.forecastdata["item2_temperature_high"])
                                        return weatherData.meecastData.forecastdata["item2_temperature_low"]  + '°' + "\n"+  weatherData.meecastData.forecastdata["item2_temperature_high"]  + '°'     
                                    else
                                        return ""
                                }
                            }
                        }

                    }
                }
            }
            Row {
                id: forecast3_row
                Column {
                    id: icon_day_column3
                    Label {
                        id: day_name_3 
                        anchors.bottom: icon_3.top 
                        anchors.bottomMargin: -Theme.paddingSmall
                        font.pixelSize: Theme.fontSizeSmall 
                        color: Theme.secondaryColor
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                        text: weatherData.meecastData.forecastdata["item3_short_day_name"]
                    }
                    Row{
                        Image {
                            id: icon3
                            height: Screen.sizeCategory >= Screen.Large ? Theme.itemSizeLarge : Theme.itemSizeSmall 
                            width: height
                            source: weatherData.meecastData.forecastdata["item3_icon"]
                        }
                        Label {
                            id: temperature_3 
                            font.pixelSize: Theme.fontSizeSmall
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: icon3.height
                            wrapMode: Text.Wrap
                            width: 1.6*Theme.fontSizeSmall
                            text: {
                                if ( weatherData.meecastData.forecastdata["item3_temperature_high"] == "N/A" || weatherData.meecastData.forecastdata["item3_temperature_low"] == "N/A" ){   
                                    return weatherData.meecastData.forecastdata["item3_temperature"] + '°'                        }else{
                                    if (weatherData.meecastData.forecastdata["item3_temperature_low"] && weatherData.meecastData.forecastdata["item3_temperature_high"])
                                        return weatherData.meecastData.forecastdata["item3_temperature_low"]  + '°' + "\n"+  weatherData.meecastData.forecastdata["item3_temperature_high"]  + '°'     
                                    else
                                        return ""
                                }
                            }
                        }

                    }
                }
            }
            Row {
                id: forecast4_row
                Column {
                    id: icon_day_column4
                    Label {
                        id: day_name_4 
                        anchors.bottom: icon_4.top 
                        anchors.bottomMargin: -Theme.paddingSmall
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                        text: weatherData.meecastData.forecastdata["item4_short_day_name"]
                    }
                    Row {
                        Image {
                            id: icon4
                            height: Screen.sizeCategory >= Screen.Large ? Theme.itemSizeLarge : Theme.itemSizeSmall
                            width: height
                            source: weatherData.meecastData.forecastdata["item4_icon"]
                        }
                        Label {
                            id: temperature_4 
                            font.pixelSize: Theme.fontSizeSmall
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: icon4.height
                            wrapMode: Text.Wrap
                            width: 1.6*Theme.fontSizeSmall
                            text: {
                                if ( weatherData.meecastData.forecastdata["item4_temperature_high"] == "N/A" || weatherData.meecastData.forecastdata["item4_temperature_low"] == "N/A" ){   
                                    return weatherData.meecastData.forecastdata["item4_temperature"] + '°'                        }else{
                                    if (weatherData.meecastData.forecastdata["item4_temperature_low"] && weatherData.meecastData.forecastdata["item4_temperature_high"])
                                        return weatherData.meecastData.forecastdata["item4_temperature_low"]  + '°' + "\n"+  weatherData.meecastData.forecastdata["item4_temperature_high"]  + '°'     
                                    else
                                        return ""
                                }
                            }
                        }
                    }
                }
            }
            Row {
                id: forecast5_row
                Column {
                    id: icon_day_column5
                    Label {
                        id: day_name_5 
                        anchors.bottom: icon_5.top 
                        anchors.bottomMargin: -Theme.paddingSmall
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                        text: weatherData.meecastData.forecastdata["item5_short_day_name"]
                    }
                    Row {
                        Image {
                            id: icon5
                            height: Screen.sizeCategory >= Screen.Large ? Theme.itemSizeLarge : Theme.itemSizeSmall
                            width: height
                            source: weatherData.meecastData.forecastdata["item5_icon"]
                        }
                        Label {
                            id: temperature_5 
                            font.pixelSize: Theme.fontSizeSmall
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: icon5.height
                            wrapMode: Text.Wrap
                            width: 1.6*Theme.fontSizeSmall
                            text: {
                                if ( weatherData.meecastData.forecastdata["item5_temperature_high"] == "N/A" || weatherData.meecastData.forecastdata["item5_temperature_low"] == "N/A" ){
                                    return weatherData.meecastData.forecastdata["item5_temperature"] + '°'
                                }else{
                                    if (weatherData.meecastData.forecastdata["item5_temperature_low"] && weatherData.meecastData.forecastdata["item5_temperature_high"])
                                        return weatherData.meecastData.forecastdata["item5_temperature_low"]  + '°' + "\n"+  weatherData.meecastData.forecastdata["item5_temperature_high"]  + '°'     
                                    else
                                        return ""
                                }
                            }
                        }
                    }
                }
            }
            Row {
                id: forecast6_row
                visible: isPortrait ? false : true
                enabled: isPortrait ? false : true
                Column {
                    id: icon_day_column6
                    Label {
                        id: day_name_6 
                        anchors.bottom: icon_6.top 
                        anchors.bottomMargin: -Theme.paddingSmall
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                        text: weatherData.meecastData.forecastdata["item6_short_day_name"]
                    }
                    Row {
                        Image {
                            id: icon6
                            height: Screen.sizeCategory >= Screen.Large ? Theme.itemSizeLarge : Theme.itemSizeSmall
                            width: height
                            source: weatherData.meecastData.forecastdata["item6_icon"]
                        }
                        Label {
                            id: temperature_6 
                            font.pixelSize: Theme.fontSizeSmall
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: icon6.height
                            wrapMode: Text.Wrap
                            width: 1.6*Theme.fontSizeSmall
                            text: {
                                if ( weatherData.meecastData.forecastdata["item6_temperature_high"] == "N/A" || weatherData.meecastData.forecastdata["item6_temperature_low"] == "N/A" ){
                                    return weatherData.meecastData.forecastdata["item6_temperature"] + '°'
                                }else{
                                    if (weatherData.meecastData.forecastdata["item6_temperature_low"] && weatherData.meecastData.forecastdata["item6_temperature_high"])
                                        return weatherData.meecastData.forecastdata["item6_temperature_low"]  + '°' + "\n"+  weatherData.meecastData.forecastdata["item6_temperature_high"]  + '°'     
                                    else
                                        return ""
                                }
                            }
                        }
                    }
                }
            }

            Row {
                id: forecast7_row
                visible: isPortrait ? false : true
                enabled: isPortrait ? false : true
                Column {
                    id: icon_day_column7
                    Label {
                        id: day_name_7 
                        anchors.bottom: icon_7.top 
                        anchors.bottomMargin: -Theme.paddingSmall
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                        text: weatherData.meecastData.forecastdata["item7_short_day_name"]
                    }
                    Row {
                        Image {
                            id: icon7
                            height: Screen.sizeCategory >= Screen.Large ? Theme.itemSizeLarge : Theme.itemSizeSmall
                            width: height
                            source: weatherData.meecastData.forecastdata["item7_icon"]
                        }
                        Label {
                            id: temperature_7 
                            font.pixelSize: Theme.fontSizeSmall
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: icon7.height
                            wrapMode: Text.Wrap
                            width: 1.6*Theme.fontSizeSmall
                            text: {
                                if ( weatherData.meecastData.forecastdata["item7_temperature_high"] == "N/A" || weatherData.meecastData.forecastdata["item7_temperature_low"] == "N/A" ){
                                    return weatherData.meecastData.forecastdata["item7_temperature"] + '°'
                                }else{
                                    if (weatherData.meecastData.forecastdata["item7_temperature_low"] && weatherData.meecastData.forecastdata["item7_temperature_high"])
                                        return weatherData.meecastData.forecastdata["item7_temperature_low"]  + '°' + "\n"+  weatherData.meecastData.forecastdata["item7_temperature_high"]  + '°'     
                                    else
                                        return ""
                                }
                            }
                        }
                    }
                }
            }
            Row {
                id: forecast8_row
                visible: isPortrait ? false : true
                enabled: isPortrait ? false : true
                Column {
                    id: icon_day_column8
                    Label {
                        id: day_name_8 
                        anchors.bottom: icon_8.top 
                        anchors.bottomMargin: -Theme.paddingSmall
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                        text: weatherData.meecastData.forecastdata["item8_short_day_name"]
                    }
                    Row {
                        Image {
                            id: icon8
                            height: Screen.sizeCategory >= Screen.Large ? Theme.itemSizeLarge : Theme.itemSizeSmall
                            width: height
                            source: weatherData.meecastData.forecastdata["item8_icon"]
                        }
                        Label {
                            id: temperature_8 
                            font.pixelSize: Theme.fontSizeSmall
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: icon7.height
                            wrapMode: Text.Wrap
                            width: 1.6*Theme.fontSizeSmall
                            text: {
                                if ( weatherData.meecastData.forecastdata["item8_temperature_high"] == "N/A" || weatherData.meecastData.forecastdata["item8_temperature_low"] == "N/A" ){
                                    return weatherData.meecastData.forecastdata["item8_temperature"] + '°'
                                }else{
                                    if (weatherData.meecastData.forecastdata["item8_temperature_low"] && weatherData.meecastData.forecastdata["item8_temperature_high"])
                                        return weatherData.meecastData.forecastdata["item8_temperature_low"]  + '°' + "\n"+  weatherData.meecastData.forecastdata["item8_temperature_high"]  + '°'     
                                    else
                                        return ""
                                }
                            }
                        }
                    }
                }
            }

        }
        Row {
            height: 0
            opacity: 0.0
            id: lastupdate_row
            width: parent.width
            states: State {
                name: "expanded"
                when: weatherData.expanded
                PropertyChanges {
                    target: lastupdate_row
                    opacity: 1.0
                    height: Theme.itemSizeExtrasSmall
                }
            }

            Label {
                id: last_update
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall 
                color: Theme.secondaryColor
                horizontalAlignment: Text.AlignRight
                text: "Last update: " + weatherData.meecastData.forecastdata["last_update"]
            }
        }
    }
    Connections {
        target: weatherData.meecastData 
        onRefreshWidget: {            
            console.log("Refresh MeeCast widget !!!!!!!!!!!!!!")
            weatherData.refresh();
        }
    }

}
