import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core
import Qt5Compat.GraphicalEffects

// ***********************************************************
// weather app - twc weather data
// txhammer
// 1/2023
// ***********************************************************

Item {
    id:root
    visible: true
    width: 840
    height:650

    property var weatherCurrentConditions:["Real Feel","Humidity","Wind","DewPoint","Visibility","Rainfall","Pressure","UVI","AQI"]
    property var weatherCurrentConditionsValues:[weather.temperatureFeelsLike+"°",weather.relativeHumidity+"%",weather.windDirectionCardinal+" "+weather.windSpeed,weather.temperatureDewPoint+"°",weather.visibility,weather.precip24Hour+"\x22",weather.pressureAltimeter,weather.uvDescription,airQuality.globalairquality.airQualityCategory]

    Image {
        id:background
        anchors.fill:parent
        source:img1

        Row {
            id:currents
            height:40
            spacing:10
            //width:220
            anchors.horizontalCenter:parent.horizontalCenter
            anchors.top:parent.top
            anchors.topMargin:10

            Image {
                source:"./icons/"+weather.iconCode+".png"
                width:56
                height:56
                smooth:true
                antialiasing : true
            }

            Text {
                text:weather.temperature+"°"
                color:"white"
                font.pointSize:20
                topPadding:10
                antialiasing : true
            }

            Text {
                text:weather.wxPhraseMedium
                font.capitalization: Font.Capitalize
                color:"white"
                font.pointSize:20
                topPadding:10
                antialiasing : true
            }
        }


        Text {
            id:alerts
            anchors.top:currents.bottom
            topPadding:20
            anchors.horizontalCenter:background.horizontalCenter
            text:weatherWarnings ? "⚠ "+warnings.alerts[0].eventDescription : wforecast.narrative[0]
            color:"white"
            font.pointSize:16
            antialiasing : true
            //visible:warnings.hasOwnProperty("alerts")
            //height:visible ? 40 : 0

            MouseArea {
                id: mouseArea
                anchors.fill: alerts
                enabled:weatherWarnings
                cursorShape: weatherWarnings  ? Qt.PointingHandCursor : Qt.ArrowCursor
                hoverEnabled: weatherWarnings  ? true : false
                onEntered: weatherWarnings  ? alerts.color="Steelblue": alerts.color="white"
                onExited: weatherWarnings ? alerts.color="white" : alerts.color="white"
                onClicked: {
                    Qt.openUrlExternally("https://alerts.weather.gov/cap/wwaatmget.php?x=TXC201&y=1")
                }
            }
        }

        Item {
            id:currentConds
            anchors.top:alerts.bottom
            anchors.left:background.left
            anchors.topMargin:25
            anchors.leftMargin:20
            height:80

            Row {
                spacing:10
                Repeater {
                    id:r2
                    model:weatherCurrentConditions.length

                    Rectangle {
                        //anchors.leftMargin:2
                        antialiasing : true
                        smooth:true
                        width:80
                        height:70
                        //border.color: colorRange (index)
                        color: Qt.rgba(13, 13, 13, 0.10) // set opacity just for rect
                        radius:4

                        Rectangle{
                            anchors.bottom:parent.bottom
                            anchors.left:parent.left
                            anchors.leftMargin:10
                            anchors.bottomMargin:5
                            width:60
                            height:2
                            radius:4
                            color:Qt.rgba(0, 0, 0, 0.80)

                            Rectangle{
                                anchors.left:parent.left
                                anchors.bottom:parent.bottom
                                width:colorGauge (index)
                                height:2
                                radius:4
                                color:colorRange (index)
                            }
                        }


                        Text {
                            anchors.top:parent.top
                            anchors.horizontalCenter:parent.horizontalCenter
                            anchors.topMargin:5
                            text:weatherCurrentConditions[index]
                            color:"white"
                            font.pointSize:11
                            font.bold:true
                            antialiasing : true

                            Text {
                                anchors.top:parent.bottom
                                anchors.horizontalCenter:parent.horizontalCenter
                                anchors.topMargin:7
                                text:weatherCurrentConditionsValues[index] == ("Unhealthy for Sensitive Groups") ? "Unhealthy" : weatherCurrentConditionsValues[index]
                                color:"white"
                                //width:80*.95
                                //elide: Text.ElideRight
                                //wrapMode: Text.NoWrap
                                font.pointSize:text.length > 7 ? 13:16
                                antialiasing : true
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id:hourly
            color:"gray"
            opacity:.15
            width:background.width*.95
            anchors.leftMargin:20
            anchors.topMargin:10
            height:80
            radius:8
            anchors.top:currentConds.bottom
            anchors.left:background.left
            antialiasing : true
            smooth:true
            //anchors.horizontalCenter:root.horizontalCenter
            z:1
        }

        Component{
            id:hourlyList

            Text {
                text:Qt.formatTime(new Date(whourly.validTimeUtc[index]*1000))
                color:"white"
                font.pointSize:10
                antialiasing : true
                font.bold:true
                width:64

            Rectangle {
                width:parent.width*1.15
                height:24
                anchors.top:parent.bottom
                anchors.topMargin:5
                anchors.horizontalCenter:parent.horizontalCenter
                color:"transparent"
                //border.color:"gray"
                antialiasing : true
                radius:6
                smooth:true

                Image {
                    //anchors.verticalCenter:parent.verticalCenter
                    anchors.top:parent.top
                    anchors.horizontalCenter:parent.horizontalCenter
                    anchors.topMargin:-7
                    //anchors.left:parent.left
                    source:"./icons/"+whourly.iconCode[index]+".png"
                    width:28
                    height:28
                    smooth:true
                    antialiasing : true
                    //anchors.leftMargin:-5
                    //anchors.rightMargin:15
                }

                    Text {
                        anchors.top:parent.top
                        anchors.topMargin:25
                        anchors.horizontalCenter:parent.horizontalCenter
                        //anchors.left:parent.right
                        text:Math.round(whourly.temperature[index])+"°  ~ "+Math.floor(whourly.precipChance[index]/10)*10+"%"
                        color:"white"
                        font.pointSize:10
                        antialiasing : true
                    }
                }
              }
            }

        ListView {
            id:listView
            focus:true
            spacing:15
            anchors.fill:hourly
            anchors.leftMargin:20
            anchors.rightMargin:10
            anchors.topMargin:10
            contentHeight: 30
            model:whourly.temperature
            contentWidth: background.width*.97  // 1 of 2 newly inserted lines of code
            //flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds
           // maximumFlickVelocity:24
            snapMode: ListView.SnapToItem
            orientation:ListView.Horizontal
            layoutDirection:Qt.LeftToRight
            //flickableDirection: Flickable.AutoFlickDirection
            //cacheBuffer:315*18
            //highlight:highlightView
            clip:true
            interactive:false
            //keyNavigationEnabled: true
            //keyNavigationWraps: false // endless scrolling
            delegate:hourlyList

            ScrollBar.horizontal: ScrollBar {
                id:scroll
                //policy: ScrollBar.AsNeeded
                orientation: Qt.Horizontal
                stepSize:.025
                //size:.
                parent: listView.parent
                hoverEnabled: true
                active: hovered || pressed
                interactive: false
                //anchors.top:listView.top
                //anchors.bottom:listView.bottom
                //anchors.left:listView.left
                //anchors.right:listView.right
                anchors.fill:listView
                contentItem: Rectangle {
                    id:rect1
                    implicitWidth: 4
                    //implicitHeight:contentItem.height/4
                    radius:6
                    color: "white"
                    antialiasing:true
                    smooth:true
                    opacity:scroll.active ? 1:0
                    Behavior on opacity {
                        OpacityAnimator {
                            duration: units.longDuration
                            easing.type: opacity ? Easing.OutCubic:Easing.InCubic
                        }}
                }
                background: Rectangle {
                    id:rect2
                    implicitWidth: 4
                    radius:6
                    opacity:scroll.active  ? .65:0
                    color: "black"
                    antialiasing:true
                    smooth:true
                    Behavior on opacity {
                        OpacityAnimator {
                            duration: units.longDuration
                            easing.type: opacity ? Easing.OutCubic:Easing.InCubic
                        }}
                }
                MouseArea {
                    anchors.fill: parent
                    onWheel: {
                        if (wheel.angleDelta.y > 0) scroll.decrease()
                            else scroll.increase()
                    }
                }
            }
        }
        Rectangle {
            id:forecast
            anchors.top:hourly.bottom
            anchors.left:hourly.left
            anchors.topMargin:20
            width:260
            height:300
            color:"gray"
            opacity:.15
            radius:8
            antialiasing : true
            smooth:true
            z:1
        }
        Column {
            anchors.centerIn:forecast
            height:280
            width:260
            spacing:13;
            Repeater {
                id:r1
                model:7
                RowLayout {
                    spacing:28
                    Text {
                        text:Qt.formatDate(new Date(wforecast.validTimeUtc[index]*1000),"ddd");
                        color:"white"
                        font.pointSize:12
                        font.bold:true
                        antialiasing : true
                        Layout.fillWidth:true
                        Layout.preferredWidth:36
                        horizontalAlignment: Text.AlignRight
                        leftPadding:10
                    }

                    Image {
                        //source : "./icons/"+wforecast.daypart[0].iconCode[index < 2 ? 0 : index*2]+".png"
                        source:forecastIcons[index]
                        Layout.preferredHeight:28
                        Layout.preferredWidth:28
                        Layout.fillWidth:true
                        Layout.alignment:Text.AlignRight
                        antialiasing : true
                        smooth:true
                    }

                    Text {
                        //text:Math.floor(wforecast.daypart[0].precipChance[index < 2 ? 0 : index*2]/10)*10+"% "
                        text:forecastRains[index]
                        color:"white"
                        font.pointSize:12
                        antialiasing : true
                        Layout.fillWidth:true
                        Layout.preferredWidth:5
                        Layout.leftMargin:40
                        horizontalAlignment: Text.AlignRight
                    }

                    Text {
                        text:wforecast.calendarDayTemperatureMin[index]+"°"+" | "+ wforecast.calendarDayTemperatureMax[index]+"°  "
                        color:"white"
                        font.pointSize:12
                        antialiasing : true
                        Layout.preferredWidth:20
                        Layout.alignment:Text.AlignRight
                        Layout.fillWidth:true
                    }
                }
            }

        }

        Rectangle {
            id:radar
            anchors.top:forecast.top
            anchors.left:forecast.right
            anchors.leftMargin:20
            width:520
            height:300
            color:"gray"
            opacity:.15
            radius:8
            antialiasing : true
            smooth:true
            z:1
        }

        Image {
            id:radarLoop
            source:radarImage
            anchors.horizontalCenter:radar.horizontalCenter
            anchors.verticalCenter:radar.verticalCenter
            //anchors.top:radar.top
            //anchors.topMargin:5
            smooth: false // allow opacity mask == false
            width: radar.width*.992
            //height: radar.height*.992
            fillMode:Image.PreserveAspectFit
            visible: false
        }

        MouseArea {
            anchors.fill: radarLoop
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            hoverEnabled: true
            cursorShape:Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally("https://abc13.com/weather/")
        }

        OpacityMask {
            anchors.fill: radarLoop
            source: radarLoop
            maskSource: Rectangle {    // whats behind mask is visible, adds rounded corners to radar image
                width: radarLoop.width*.992
                height: radarLoop.height*.992
                radius: 8
                antialiasing : true
                visible: false // this also needs to be invisible or it will cover up the image
            }
        }
    }
     function colorRange (x) {
        switch (x)  {
            case 0:
                if (weather.temperatureFeelsLike < 29) {
                    return "cyan" }
                else if (weather.temperatureFeelsLike > 28 && weather.temperatureFeelsLike < 49 ) {
                    return "steelblue" }
                else if (weather.temperatureFeelsLike > 48 && weather.temperatureFeelsLike < 75 ) {
                    return "green" }
                else if (weather.temperatureFeelsLike > 74 && weather.temperatureFeelsLike < 86 ) {
                    return "yellow" }
                else if (weather.temperatureFeelsLike > 85 && weather.temperatureFeelsLike < 97 ) {
                    return "#ff8446" }
                else if (weather.temperatureFeelsLike > 96 && weather.temperatureFeelsLike < 111 ) {
                    return "red" }
                else if (weather.temperatureFeelsLike > 110) {
                    return "magenta" }
            case 1:
                 if (weather.relativeHumidity < 19) {
                    return "#aaffff" }
                else if (weather.relativeHumidity > 18 && weather.relativeHumidity < 29 ) {
                    return "#7bffb2" }
                else if (weather.relativeHumidity > 28 && weather.relativeHumidity < 39 ) {
                    return "green" }
                else if (weather.relativeHumidity > 38 && weather.relativeHumidity < 74 ) {
                    return "yellow" }
                else if (weather.relativeHumidity > 73 && weather.relativeHumidity < 90 ) {
                    return "#ff8446" }
                else if (weather.relativeHumidity > 89 && weather.relativeHumidity < 101 ) {
                    return "#0079b1" }
            case 2:
                 if (weather.windSpeed < 1) {
                    return "#aaffff" }
                else if (weather.windSpeed > 1 && weather.windSpeed < 17 ) {
                    return "green" }
                else if (weather.windSpeed > 16 && weather.windSpeed < 40 ) {
                    return "yellow" }
                else if (weather.windSpeed > 39 && weather.windSpeed < 59 ) {
                    return "#ff8446" }
                else if (weather.windSpeed > 58 && weather.windSpeed < 120 ) {
                    return "red" }
                else if (weather.windSpeed > 119) {
                    return "magenta" }
             case 3:
                 if (weather.temperatureDewPoint < 50) {
                    return "cyan" }
                else if (weather.temperatureDewPoint > 49 && weather.temperatureDewPoint < 60 ) {
                    return "#7bffb2" }
                else if (weather.temperatureDewPoint > 59 && weather.temperatureDewPoint < 65 ) {
                    return "green" }
                else if (weather.temperatureDewPoint > 64 && weather.temperatureDewPoint < 74 ) {
                    return "yellow" }
                else if (weather.temperatureDewPoint > 73 && weather.temperatureDewPoint < 81 ) {
                    return "#ff8446" }
                else if (weather.temperatureDewPoint > 80) {
                    return "magenta" }
             case 4:
                 if (weather.visibility < .90) {
                    return "red" }
                else if (weather.visibility > 1 && weather.visibility < 4 ) {
                    return "#ff8446" }
                else if (weather.visibility > 3 && weather.visibility < 7 ) {
                    return "yellow" }
                else if (weather.visibility > 6) {
                    return "green" }
            case 5:
                 if (weather.precip24Hour < .099) {
                    return "#aaffff" }
                else if (weather.precip24Hour > .099 && weather.precip24Hour < 2 ) {
                    return "green" }
                else if (weather.precip24Hour > 1.9 && weather.precip24Hour < 3 ) {
                    return "yellow" }
                else if (weather.precip24Hour > 2.9 && weather.precip24Hour < 4 ) {
                    return "#ff8446" }
                else if (weather.precip24Hour > 3.9 && weather.precip24Hour < 5 ) {
                    return "red" }
                else if (weather.precip24Hour > 4.9) {
                    return "magenta" }
            case 6:
                 if (weather.pressureAltimeter > 30.2) {
                    return "cyan" }
                else if (weather.pressureAltimeter < 30.1 && weather.pressureAltimeter > 29.8 ) {
                    return "green" }
                else if (weather.pressureAltimeter < 29.7 && weather.pressureAltimeter > 29.6 ) {
                    return "yellow" }
                else if (weather.pressureAltimeter < 29.5 ){
                    return "#ff8446" }
            case 7:
                 if (weather.uvDescription =="Low") {
                    return "green" }
                 else if (weather.uvDescription =="Moderate") {
                    return "yellow" }
                 else if (weather.uvDescription =="High") {
                    return "#ff8446" }
                 else if (weather.uvDescription =="Very High") {
                    return "red" }
                 else if (weather.uvDescription =="Extreme") {
                    return "magenta" }
                 else if (weather.uvDescription == "No Report" || weather.uvDescription =="Not Available" ) {
                    return "yellow" }
            case 8:
                 if (airQuality.globalairquality.airQualityCategory =="Good") {
                    return "green" }
                 else if (airQuality.globalairquality.airQualityCategory =="Moderate") {
                    return "yellow" }
                 else if (airQuality.globalairquality.airQualityCategory =="Unhealthy for Sensitive Groups") {
                    return "#ff8446" }
                 else if (airQuality.globalairquality.airQualityCategory =="Unhealthy") {
                    return "red" }
                 else if (aairQuality.globalairquality.airQualityCategory == "Very Unhealthy" || airQuality.globalairquality.airQualityCategory == "Hazardous")  {
                    return "magenta" }
                 else if (airQuality.globalairquality.airQualityCategory == "No Report" || airQuality.globalairquality.airQualityCategory =="Not Available" ) {
                    return "yellow" }
        }
    }

    function colorGauge (x) {
        switch (x)  {
            case 0:
                if (weather.temperatureFeelsLike < 29) {
                    return 10 }
                else if (weather.temperatureFeelsLike > 28 && weather.temperatureFeelsLike < 49 ) {
                    return 15 }
                else if (weather.temperatureFeelsLike > 48 && weather.temperatureFeelsLike < 75 ) {
                    return 20 }
                else if (weather.temperatureFeelsLike > 74 && weather.temperatureFeelsLike < 86 ) {
                    return 30 }
                else if (weather.temperatureFeelsLike > 85 && weather.temperatureFeelsLike < 94 ) {
                    return 40 }
                else if (weather.temperatureFeelsLike > 93 && weather.temperatureFeelsLike < 99 ) {
                    return 50 }
                else if (weather.temperatureFeelsLike > 98) {
                    return 60 }
            case 1:
                 if (weather.relativeHumidity < 19) {
                    return 10 }
                else if (weather.relativeHumidity > 18 && weather.relativeHumidity < 29 ) {
                    return 15 }
                else if (weather.relativeHumidity > 28 && weather.relativeHumidity < 39 ) {
                    return 20 }
                else if (weather.relativeHumidity > 38 && weather.relativeHumidity < 69 ) {
                    return 30 }
                else if (weather.relativeHumidity > 68 && weather.relativeHumidity < 79 ) {
                    return 40 }
                else if (weather.relativeHumidity > 78 && weather.relativeHumidity < 98 ) {
                    return 52 }
                else if (weather.relativeHumidity > 97) {
                    return 60 }
            case 2:
                 if (weather.windSpeed < 1) {
                    return 1 }
                else if (weather.windSpeed > 1 && weather.windSpeed < 15 ) {
                    return 10 }
                else if (weather.windSpeed > 14 && weather.windSpeed < 25 ) {
                    return 20 }
                else if (weather.windSpeed > 24 && weather.windSpeed < 40 ) {
                    return 30 }
                else if (weather.windSpeed > 39 && weather.windSpeed < 59 ) {
                    return 40 }
                else if (weather.windSpeed > 58 && weather.windSpeed < 119 ) {
                    return 50 }
                else if (weather.windSpeed > 118) {
                    return 60 }
             case 3:
                 if (weather.temperatureDewPoint < 50) {
                    return 10 }
                else if (weather.temperatureDewPoint > 49 && weather.temperatureDewPoint < 60 ) {
                    return 20 }
                else if (weather.temperatureDewPoint > 59 && weather.temperatureDewPoint < 65 ) {
                    return 30 }
                else if (weather.temperatureDewPoint > 64 && weather.temperatureDewPoint < 74 ) {
                    return 40 }
                else if (weather.temperatureDewPoint > 73 && weather.temperatureDewPoint < 81 ) {
                    return 52 }
                else if (weather.temperatureDewPoint > 80) {
                    return 60 }
             case 4:
                 if (weather.visibility < 1) {
                    return 20 }
                else if (weather.visibility > 1 && weather.visibility < 4 ) {
                    return 33 }
                else if (weather.visibility > 3 && weather.visibility < 8 ) {
                    return 45 }
                else if (weather.visibility > 7) {
                    return 60 }
            case 5:
                 if (weather.precip24Hour < .099) {
                    return 0 }
                else if (weather.precip24Hour > .01 && weather.precip24Hour < 1 ) {
                    return 10 }
                else if (weather.precip24Hour > .9 && weather.precip24Hour < 2 ) {
                    return 20 }
                else if (weather.precip24Hour > 1.9 && weather.precip24Hour < 4 ) {
                    return 35 }
                else if (weather.precip24Hour > 3.9 && weather.precip24Hour < 5 ) {
                    return 45 }
                else if (weather.precip24Hour > 4.9) {
                    return 60 }
            case 6:
                 if (weather.pressureAltimeter > 30.2) {
                    return 50 }
                else if (weather.pressureAltimeter < 30.1 && weather.pressureAltimeter > 29.8 ) {
                    return 40 }
                else if (weather.pressureAltimeter < 29.7 && weather.pressureAltimeter > 29.6 ) {
                    return 33 }
                else if (weather.pressureAltimeter < 29.5 ){
                    return 20 }
            case 7:
                 if (weather.uvDescription =="Low") {
                    return 15 }
                 else if (weather.uvDescription =="Moderate") {
                    return 33 }
                 else if (weather.uvDescription =="High") {
                    return 40 }
                 else if (weather.uvDescription =="Very High") {
                    return 50 }
                 else if (weather.uvDescription =="Extreme") {
                    return 60 }
                 else if (weather.uvDescription == "No Report" || weather.uvDescription =="Not Available" ) {
                    return 33 }
            case 8:
                 if (airQuality.globalairquality.airQualityCategory =="Good") {
                    return 15 }
                 else if (airQuality.globalairquality.airQualityCategory =="Moderate") {
                    return 33 }
                 else if (airQuality.globalairquality.airQualityCategory =="Unhealthy for Sensitive Groups") {
                    return 40 }
                 else if (airQuality.globalairquality.airQualityCategory =="Unhealthy") {
                    return 50 }
                 else if (airQuality.globalairquality.airQualityCategory == "Very Unhealthy" || airQuality.globalairquality.airQualityCategory == "Hazardous")  {
                    return 60 }
                 else if (airQuality.globalairquality.airQualityCategory == "No Report" || airQuality.globalairquality.airQualityCategory =="Not Available" ) {
                    return 33 }
        }
    }
}
